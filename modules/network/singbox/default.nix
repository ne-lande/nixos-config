# sing-box driven by base64 node-link subscriptions.
#
# Fetches every URL in `subscriptionUrlsFile` (one per line; the file is the
# secret — it is referenced by path and never copied into the store), converts
# the share links (ss/vmess/vless/trojan/hysteria2) into outbounds and renders
# a config with:
#   - a mixed HTTP+SOCKS inbound on listenAddress:port — point apps at it,
#     e.g. http_proxy=http://127.0.0.1:2080 or socks5h://127.0.0.1:2080
#   - an urltest group "auto" picking the lowest-latency node
#   - a selector "proxy" (defaults to auto) switchable via the clash API:
#     curl -X PUT 127.0.0.1:9090/proxies/proxy -d '{"name":"<node tag>"}'
# The updater runs before singbox at boot and on a timer; configs are
# validated with `sing-box check` and swapped atomically.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.network.singbox;
in
{
  options.network.singbox = {
    enable = mkEnableOption "subscription-driven sing-box proxy";

    package = mkPackageOption pkgs "sing-box" { };

    subscriptionUrlsFile = mkOption {
      type = types.path;
      description = ''
        File containing one base64 subscription URL per line.
        Secret: referenced by path at runtime, never copied into the store.
      '';
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Mixed (HTTP+SOCKS) proxy listen address.";
    };

    port = mkOption {
      type = types.port;
      default = 2080;
      description = "Mixed (HTTP+SOCKS) proxy port.";
    };

    clashApiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Clash API listen address for manual selector switching.";
    };

    clashApiPort = mkOption {
      type = types.port;
      default = 9090;
      description = "Clash API port for manual selector switching.";
    };

    updateInterval = mkOption {
      type = types.str;
      default = "6h";
      description = "Subscription refresh interval (systemd time span).";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.singbox-update = {
      description = "sing-box subscription updater";
      # sops-nix installs /run/secrets before we read the URLs file; the
      # Wants/After are harmless on hosts without sops (systemd ignores
      # missing units in these dependencies)
      wants = [
        "network-online.target"
        "sops-nix.service"
      ];
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      # 5 retries in 10 min: enough for any transient outage (a switch
      # restarting NetworkManager/wpa_supplicant, a WiFi hiccup); past the
      # burst limit the unit stays failed and visible instead of looping
      # forever against a dead upstream — the timer retries it later.
      startLimitIntervalSec = 600;
      startLimitBurst = 5;
      before = [ "singbox.service" ];
      serviceConfig = {
        Type = "oneshot";
        # StateDirectory, not RuntimeDirectory: a shared /run dir is removed
        # by systemd once every owning unit goes inactive (e.g. singbox
        # condition-skipped), which races away the just-written config
        StateDirectory = "singbox";
        ExecStart = concatStringsSep " " [
          "${pkgs.python3}/bin/python3"
          "${./subscribe.py}"
          "--urls-file ${cfg.subscriptionUrlsFile}"
          "--output-dir /var/lib/singbox"
          "--sing-box ${cfg.package}/bin/sing-box"
          "--listen ${cfg.listenAddress}"
          "--port ${toString cfg.port}"
          "--clash-listen ${cfg.clashApiAddress}"
          "--clash-port ${toString cfg.clashApiPort}"
          "--cache-file /var/lib/singbox/cache.db"
        ];
        # pick up refreshed configs on timer runs, and (re)start singbox if
        # it is inactive — e.g. skipped at boot because the first update
        # failed before any config existed.
        # --no-block is mandatory: a synchronous restart would deadlock —
        # singbox is After=this unit, so its start job waits for this unit
        # to go active, which cannot happen while this ExecStartPost runs
        ExecStartPost = "+${pkgs.systemd}/bin/systemctl --no-block restart singbox.service";
        # A timer/switch-triggered run can land in the seconds-long window
        # where the network is restarting (fetches fail instantly, DNS is
        # gone) — network-online.target can't help, it was reached at boot
        # and never deactivates. Retry after the interface settles; the
        # config is only replaced on a successful run, and ExecStartPost
        # (restart singbox) is skipped on failed attempts. Requires
        # systemd >= 244 (Restart= on oneshots).
        Restart = "on-failure";
        RestartSec = "30s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = "read-only";
      };
    };

    systemd.timers.singbox-update = {
      description = "sing-box subscription refresh";
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.updateInterval;
        RandomizedDelaySec = "30s";
        Persistent = true;
      };
    };
    systemd.services.singbox = {
      description = "sing-box proxy";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "singbox-update.service"
      ];
      after = [
        "network-online.target"
        "singbox-update.service"
      ];
      # start only once the updater has produced a config; otherwise skip
      # cleanly instead of crash-looping (the updater's ExecStartPost starts
      # us as soon as a config appears)
      unitConfig.ConditionPathExists = "/var/lib/singbox/config.json";
      serviceConfig = {
        StateDirectory = "singbox";
        ExecStart = "${cfg.package}/bin/sing-box run -D /var/lib/singbox -c /var/lib/singbox/config.json";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        # AF_NETLINK: auto_detect_interface subscribes to route updates over
        # rtnetlink; without it sing-box dies with "address family not
        # supported by protocol" at startup
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";
        ReadWritePaths = [ "/var/lib/singbox" ];
      };
    };
  };
}
