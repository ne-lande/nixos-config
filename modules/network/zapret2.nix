{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  zapret2-run = pkgs.writeShellScriptBin "zapret2-run" ''
    set -euo pipefail

    NETNS="zapret2"

    if [ $# -eq 0 ]; then
      echo "Usage: zapret2-run <command> [args...]"
      exit 1
    fi

    if ! ${pkgs.iproute2}/bin/ip netns list | grep -q "^zapret2"; then
      echo "zapret2 netns not running"
      exit 1
    fi

    exec sudo -E ${pkgs.iproute2}/bin/ip netns exec "$NETNS" /run/wrappers/bin/sudo -u "$USER" -E -- "$@"
  '';
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
        "--filter-tcp=443,8443"
        "--payload=tls_client_hello"
        "--lua-desync=fake:blob=fake_default_tls:tcp_ts=-1000"
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
      default = ''
        User nobody
        Group nogroup
        Port 8889
        Listen 172.31.255.6
        Timeout 600
        Allow 127.0.0.1
        Allow 172.31.255.5
        PidFile "/tmp/zapret2-tinyproxy.pid"
      '';
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
        ] ++ config.network.zapret2.nfqws2ExtraArgs
      );
    in
    {
      environment.systemPackages = with pkgs; [
        zapret2
        zapret2-run
      ];

      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      security.sudo.extraRules = [
        {
          commands = [
            {
              command = "${pkgs.iproute2}/bin/ip netns exec zapret2 *";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
          users = [ config.central.username ];
        }
      ];

      systemd.services.zapret2 = {
        description = "zapret2 netns";
        bindsTo = [ "netns@zapret2.service" ];
        requires = [ "network-online.target" ];
        after = [ "netns@zapret2.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;

          ExecStart =
            with pkgs;
            writers.writeBash "zapret2-up" ''
              set -e

              ${iproute2}/bin/ip link add zapret2-veth0 type veth peer name zapret2-veth1
              ${iproute2}/bin/ip link set zapret2-veth1 netns zapret2

              ${iproute2}/bin/ip addr add 172.31.255.5/30 dev zapret2-veth0
              ${iproute2}/bin/ip link set zapret2-veth0 up

              ${iproute2}/bin/ip -n zapret2 addr add 172.31.255.6/30 dev zapret2-veth1
              ${iproute2}/bin/ip -n zapret2 link set zapret2-veth1 up
              ${iproute2}/bin/ip -n zapret2 link set lo up

              ${iproute2}/bin/ip -n zapret2 route add default via 172.31.255.5

              ${iptables}/bin/iptables -t nat -A POSTROUTING -s 172.31.255.4/30 -j MASQUERADE

              # TCP (conntrack early packets only)
              ${iproute2}/bin/ip netns exec zapret2 ${iptables}/bin/iptables \
                -t mangle -A OUTPUT -o zapret2-veth1 \
                -p tcp \
                -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
                -m mark ! --mark 0x40000000/0x40000000 \
                -j NFQUEUE --queue-num 201 --queue-bypass

              # QUIC bypass via nfqws2 (same queue as TCP)
              ${iproute2}/bin/ip netns exec zapret2 ${iptables}/bin/iptables \
                -t mangle -A OUTPUT -o zapret2-veth1 \
                -p udp --dport 443 \
                -m mark ! --mark 0x40000000/0x40000000 \
                -j NFQUEUE --queue-num 201 --queue-bypass

              ${iproute2}/bin/ip netns exec zapret2 ${zapret2}/bin/nfqws2 \
                ${nfqws2Args} \
                --daemon

              ${iproute2}/bin/ip netns exec zapret2 ${tinyproxy}/bin/tinyproxy -c ${tinyproxyConfFile}
            '';

          ExecStop =
            with pkgs;
            writers.writeBash "zapret2-down" ''
              ${iptables}/bin/iptables -t nat -D POSTROUTING -s 172.31.255.4/30 -j MASQUERADE
              ${iproute2}/bin/ip netns exec zapret2 ${iptables}/bin/iptables \
                -t mangle -D OUTPUT -o zapret2-veth1 \
                -p udp --dport 443 \
                -m mark ! --mark 0x40000000/0x40000000 \
                -j NFQUEUE --queue-num 201 --queue-bypass || true

              ${iproute2}/bin/ip link del zapret2-veth0

              ${procps}/bin/pkill -F /tmp/zapret2-tinyproxy.pid || true
              ${procps}/bin/pkill -F /tmp/zapret2.pid || true
            '';
        };
      };
    }
  );
}
