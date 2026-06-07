{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  zdy = pkgs.fetchFromGitHub {
    "owner" = "Flowseal";
    "repo" = "zapret-discord-youtube";
    "rev" = "9a1ce92593bd9af4e2e0b4af4d9db69c71e4af00";
    "hash" = "sha256-k81WLuDrvG3zjVf3wVgnUTrpomJbuipGJv3TGX7suqc=";
  };
  bin = "${zdy}/bin";
  zapret-run = pkgs.writeShellScriptBin "zapret-run" ''
    set -euo pipefail

    NETNS="zapret"

    if [ $# -eq 0 ]; then
      echo "Usage: zapret-run <command> [args...]"
      exit 1
    fi

    if ! ${pkgs.iproute2}/bin/ip netns list | grep -q "^zapret"; then
      echo "zapret netns not running"
      exit 1
    fi

    exec sudo -E ${pkgs.iproute2}/bin/ip netns exec "$NETNS" /run/wrappers/bin/sudo -u "$USER" -E -- "$@"
  '';
in
{
  options.network.zapret = {
    enable = mkEnableOption "enable zapret";
    tinyProxyConf = mkOption {
      type = types.lines;
      default = ''
        User nobody
        Group nogroup
        Port 8888
        Listen 172.31.255.2
        Timeout 600
        Allow 127.0.0.1
        Allow 172.31.255.1
        PidFile "/tmp/zapret-tinyproxy.pid"
      '';
      description = "Path to the tinyproxy configuration file";
    };
  };

  config = mkIf config.network.zapret.enable (
    let
      tinyproxyConfFile = pkgs.writeText "tinyproxy-zapret.conf" config.network.zapret.tinyProxyConf;
    in
    {
      environment.systemPackages = with pkgs; [
        zapret
        zapret-run
      ];

      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      security.sudo.extraRules = [
        {
          commands = [
            {
              command = "${pkgs.iproute2}/bin/ip netns exec zapret *";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
          users = [ config.central.username ];
        }
      ];

      systemd.services.zapret = {
        description = "zapret netns";
        bindsTo = [ "netns@zapret.service" ];
        requires = [ "network-online.target" ];
        after = [ "netns@zapret.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;

          ExecStart =
            with pkgs;
            writers.writeBash "zapret-up" ''
              set -e

              ${iproute2}/bin/ip link add zapret-veth0 type veth peer name zapret-veth1
              ${iproute2}/bin/ip link set zapret-veth1 netns zapret

              ${iproute2}/bin/ip addr add 172.31.255.1/30 dev zapret-veth0
              ${iproute2}/bin/ip link set zapret-veth0 up

              ${iproute2}/bin/ip -n zapret addr add 172.31.255.2/30 dev zapret-veth1
              ${iproute2}/bin/ip -n zapret link set zapret-veth1 up
              ${iproute2}/bin/ip -n zapret link set lo up

              ${iproute2}/bin/ip -n zapret route add default via 172.31.255.1

              ${iptables}/bin/iptables -t nat -A POSTROUTING -s 172.31.255.0/30 -j MASQUERADE
              #$ {iproute2}/bin/ip netns exec zapret $ {iptables}/bin/iptables -t mangle -A PREROUTING -j NFQUEUE --queue-num 200
              # для HTTP/HTTPS
              ${iproute2}/bin/ip netns exec zapret ${iptables}/bin/iptables \
                -t mangle -A OUTPUT -o zapret-veth1 \
                -p tcp \
                -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
                -m mark ! --mark 0x40000000/0x40000000 \
                -j NFQUEUE --queue-num 200 --queue-bypass

              # для QUIC
              ${iproute2}/bin/ip netns exec zapret ${iptables}/bin/iptables \
                -t mangle -A OUTPUT -o zapret-veth1 \
                -p udp \
                -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
                -m mark ! --mark 0x40000000/0x40000000 \
                -j NFQUEUE --queue-num 200 --queue-bypass

              ${iproute2}/bin/ip netns exec zapret ${zapret}/bin/nfqws \
                --pidfile=/tmp/zapret.pid \
                --user nobody \
                --qnum=200 \
                --filter-udp=443 \
                --dpi-desync=fake \
                --dpi-desync-repeats=11 \
                --dpi-desync-fake-quic="${bin}/quic_initial_www_google_com.bin" \
                --filter-udp=19294-19344,50000-50100 \
                --filter-l7=discord,stun \
                --dpi-desync=fake \
                --dpi-desync-repeats=6 \
                --new \
                --filter-tcp=2053,2083,2087,2096,8443 \
                --hostlist-domains=discord.media \
                --dpi-desync=fake,multisplit \
                --dpi-desync-split-seqovl=681 \
                --dpi-desync-split-pos=1 \
                --dpi-desync-fooling=ts \
                --dpi-desync-repeats=8 \
                --dpi-desync-split-seqovl-pattern="${bin}/tls_clienthello_www_google_com.bin" \
                --dpi-desync-fake-tls="${bin}/tls_clienthello_www_google_com.bin" \
                --new \
                --filter-tcp=80,443 \
                --dpi-desync=fake,multisplit \
                --dpi-desync-split-seqovl=664 \
                --dpi-desync-split-pos=1 \
                --dpi-desync-fooling=ts \
                --dpi-desync-repeats=8 \
                --dpi-desync-split-seqovl-pattern="${bin}/tls_clienthello_max_ru.bin" \
                --dpi-desync-fake-tls="${bin}/stun.bin" \
                --dpi-desync-fake-tls="${bin}/tls_clienthello_max_ru.bin" \
                --dpi-desync-fake-http="${bin}/tls_clienthello_max_ru.bin" \
                --daemon

                ${iproute2}/bin/ip netns exec zapret ${tinyproxy}/bin/tinyproxy -c ${tinyproxyConfFile}
            '';

          ExecStop =
            with pkgs;
            writers.writeBash "zapret-down" ''
              # Remove host-netns NAT rule
              ${iptables}/bin/iptables -t nat -D POSTROUTING -s 172.31.255.0/30 -j MASQUERADE

              # Remove the veth pair (both ends go away automatically)
              ${iproute2}/bin/ip link del zapret-veth0

              # Kill daemons; mangle rules in the zapret netns are cleaned up
              # automatically when the netns@ service destroys the namespace
              ${procps}/bin/pkill -F /tmp/zapret-tinyproxy.pid || true
              ${procps}/bin/pkill -F /tmp/zapret.pid || true
            '';
        };
      };
    }
  );
}
