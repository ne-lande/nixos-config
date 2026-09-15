{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib;
let
  tp = mylib.mkTinyproxyConf {
    name = "zapret2";
    port = 8889;
    listenIp = "172.31.255.6";
    allowIps = [
      "127.0.0.1"
      "172.31.255.5"
    ];
  };
  netns-exec = mylib.mkNetnsExec pkgs "zapret2";
in
{
  options.network.zapret2 = {
    enable = mkEnableOption "enable zapret2";

    nfqws2ExtraArgs = mkOption {
      type = types.listOf types.str;
      default = [
        # HTTP: http_methodeol works across all tested domains
        "--filter-tcp=80"
        "--payload=http_req"
        "--lua-desync=http_methodeol"
        "--new"
        # HTTPS/WSS TLS: fake TLS + TCP timestamp -1000 is blockcheck's
        # first-ranked strategy for discord, abs.twimg, x.com (TLS 1.2+1.3).
        # 8443 is Discord voice WebSocket signaling.
        # ip_autottl=-3,3-20 ensures the fake packet dies before the real server
        # (TTL = hops_to_server - 3) so only the ISP DPI sees it.
        "--filter-tcp=443,8443"
        "--payload=tls_client_hello"
        "--lua-desync=fake:blob=fake_default_tls:tcp_ts=-1000:ip_autottl=-3,3-20"
        "--new"
        # QUIC: youtube TLS has no working TCP strategy at all — QUIC
        # fake_default_quic:repeats=11 is the only confirmed path for youtube.
        "--filter-udp=443"
        "--payload=quic_initial"
        "--lua-desync=fake:blob=fake_default_quic:repeats=11"
      ];
      description = "Extra arguments passed to nfqws2. See `nfqws2 --help`.";
    };

    tinyProxyConf = mkOption {
      type = types.lines;
      default = tp.conf;
      description = "tinyproxy configuration for the zapret2 namespace";
    };
  };

  config = mkIf config.network.zapret2.enable (
    let
      tinyproxyConfFile = pkgs.writeText "tinyproxy-zapret2.conf" config.network.zapret2.tinyProxyConf;
      luaBase = "${pkgs.zapret2}/share/zapret2/lua";
      nfqws2Args = concatStringsSep " \\\n                " (
        [
          "--pidfile=/tmp/zapret2.pid"
          "--user nobody"
          "--qnum=201"
          "--lua-init=@${luaBase}/zapret-lib.lua"
          "--lua-init=@${luaBase}/zapret-antidpi.lua"
        ]
        ++ config.network.zapret2.nfqws2ExtraArgs
      );
    in
    {
      environment.systemPackages = with pkgs; [
        zapret2
        netns-exec.run
      ];

      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      security.sudo = {
        extraRules = [
          (netns-exec.sudoRule // { users = [ config.central.username ]; })
        ];
        extraConfig = netns-exec.sudoEnvKeep;
      };

      systemd.services.zapret2 = mylib.mkNetnsProxyService pkgs {
        name = "zapret2";
        hostVethIp = "172.31.255.5";
        nsVethIp = "172.31.255.6";
        subnet = "172.31.255.4";
        qnum = 201;
        # TCP: conntrack early packets only; QUIC dport 443 without
        # connbytes (see upstream nfqws2 examples)
        nfqRules = [
          {
            proto = "tcp";
          }
          {
            proto = "udp";
            ports = "443";
            connbytes = false;
          }
        ];
        daemonCmd = ''
          ${pkgs.iproute2}/bin/ip netns exec zapret2 ${pkgs.zapret2}/bin/nfqws2 \
            ${nfqws2Args} \
            --daemon
        '';
        daemonPidFile = "/tmp/zapret2.pid";
        inherit tinyproxyConfFile;
        tinyproxyPidFile = tp.pidFile;
        extraDown = ''
          # Explicitly drop the QUIC mangle rule; the TCP one (and the rest
          # of the namespace) dies with netns@ destruction
          ${pkgs.iproute2}/bin/ip netns exec zapret2 ${pkgs.iptables}/bin/iptables \
            -t mangle -D OUTPUT -o zapret2-veth1 \
            -p udp --dport 443 \
            -m mark ! --mark 0x40000000/0x40000000 \
            -j NFQUEUE --queue-num 201 --queue-bypass || true
        '';
      };
    }
  );
}
