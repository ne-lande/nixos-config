{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.network.awg = {
    enable = mkEnableOption "enable awg";
    awgConfig = mkOption {
      type = types.lines;
      description = "AWG confguration";
    };
    outIp = mkOption {
      type = types.str;
      description = "IP address for the AWG output interface";
    };
    tinyProxyConf = mkOption {
      type = types.lines;
      default = ''
        User nobody
        Group nogroup
        Port 8888
        Listen 10.0.0.2
        Timeout 600
        Allow 10.0.0.1
        Allow 127.0.0.1
        PidFile "/tmp/wg-tinyproxy.pid"
      '';
      description = "Tinyproxy configuration";
    };
  };

  config = mkIf config.network.awg.enable (
    let
      tinyproxyConfFile = pkgs.writeText "tinyproxy-awg.conf" config.network.awg.tinyProxyConf;
      awgConfFile = pkgs.writeText "awg.conf" config.network.awg.awgConfig;
      awg-run = pkgs.writeShellScriptBin "awg-run" ''
        set -euo pipefail

        NETNS="awg"

        if [ $# -eq 0 ]; then
            echo "Usage: awg-run <command> [args...]"
            exit 1
        fi

        if ! ${pkgs.iproute2}/bin/ip netns list | grep -q "^awg"; then
            echo "awg netns not running"
            exit 1
        fi

        exec sudo -E ${pkgs.iproute2}/bin/ip netns exec "$NETNS" /run/wrappers/bin/sudo -u "$USER" -E -- "$@"
      '';
    in
    {
      boot.extraModulePackages = with config.boot.kernelPackages; [
        (amneziawg.overrideAttrs (old: rec {
          version = "v1.0.20260329";

          src = pkgs.fetchFromGitHub {
            owner = "amnezia-vpn";
            repo = "amneziawg-linux-kernel-module";
            rev = version;
            hash = "sha256-csKb8xFnsOYnIbnoqbpIY/R7X8OqF9O9pKC/JZH42pA=";
          };
        }))
      ];

      environment.systemPackages = with pkgs; [
        amneziawg-tools
        awg-run
      ];

      security.sudo.extraRules = [
        {
          commands = [
            {
              command = "${pkgs.iproute2}/bin/ip netns exec awg *";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
          users = [ config.central.username ];
        }
      ];

      systemd.services.awg = {
        description = "awg netns";
        bindsTo = [ "netns@awg.service" ];
        requires = [ "network-online.target" ];
        after = [ "netns@awg.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;

          ExecStart =
            with pkgs;
            writers.writeBash "awg-up" ''
              set -e

              # Set tun to default ns
              ${iproute2}/bin/ip link add awg-tun-0 type veth peer name awg-tun-1
              ${iproute2}/bin/ip link set awg-tun-1 netns awg
              ${iproute2}/bin/ip addr add 10.0.0.1/24 dev awg-tun-0
              ${iproute2}/bin/ip link set dev awg-tun-0 up
              ${iproute2}/bin/ip -n awg addr add 10.0.0.2/24 dev awg-tun-1
              ${iproute2}/bin/ip -n awg link set dev awg-tun-1 up
              ${iproute2}/bin/ip -n awg link set lo up

              # Create AWG tun
              # /run/wrappers/bin/sudo $\{amneziawg-go}/bin/amneziawg-go awg0
              # unless kernel module is supported on 6.19
              # https://github.com/amnezia-vpn/amneziawg-linux-kernel-module/issues/143
              ${iproute2}/bin/ip link add awg0 type amneziawg
              ${iproute2}/bin/ip link set awg0 netns awg
              ${iproute2}/bin/ip -n awg address add ${config.network.awg.outIp} dev awg0
              ${iproute2}/bin/ip netns exec awg ${amneziawg-tools}/bin/awg setconf awg0 ${awgConfFile}
              ${iproute2}/bin/ip -n awg link set awg0 up
              ${iproute2}/bin/ip -n awg route add default dev awg0

              # Create proxy
              ${iproute2}/bin/ip netns exec awg ${tinyproxy}/bin/tinyproxy -c ${tinyproxyConfFile}
            '';
          ExecStopPost =
            with pkgs;
            writers.writeBash "awg-down" ''
              # Remove tun
              ${iproute2}/bin/ip link del awg-tun-0

              # Remove awg links
              ${iproute2}/bin/ip -n awg route del default dev awg0
              ${iproute2}/bin/ip -n awg link del awg0

              # Kill tinyproxy
              ${procps}/bin/pkill -F /tmp/wg-tinyproxy.pid
            '';
        };
      };
    }
  );
}
