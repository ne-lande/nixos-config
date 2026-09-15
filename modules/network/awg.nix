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
    name = "awg";
    port = 8888;
    listenIp = "10.0.0.2";
    allowIps = [
      "10.0.0.1"
      "127.0.0.1"
    ];
  };
in
{
  options.network.awg = {
    enable = mkEnableOption "enable awg";
    awgConfigFile = mkOption {
      type = types.str;
      description = "Path to a runtime AWG config file (sops-nix secret or host-local file under /etc/secrets). Read directly by the awg unit; never copied into the store.";
    };
    outIp = mkOption {
      type = types.str;
      description = "IP address for the AWG output interface";
    };
    tinyProxyConf = mkOption {
      type = types.lines;
      default = tp.conf;
      description = "tinyproxy configuration for the awg namespace";
    };
  };

  config = mkIf config.network.awg.enable (
    let
      tinyproxyConfFile = pkgs.writeText "tinyproxy-awg.conf" config.network.awg.tinyProxyConf;
      netns-exec = mylib.mkNetnsExec pkgs "awg";
      awgConfFile = config.network.awg.awgConfigFile;
    in
    {
      environment.systemPackages = with pkgs; [
        amneziawg-tools
        netns-exec.run
      ];

      boot.extraModulePackages = [
        config.boot.kernelPackages.amneziawg
      ];

      # Bind-mounted over /etc/resolv.conf by `ip netns exec awg`; DNS goes
      # through the tunnel, not the host resolver, so it matches the VPN exit
      environment.etc."netns/awg/resolv.conf".text = ''
        nameserver 1.1.1.1
        nameserver 9.9.9.9
      '';

      security.sudo = {
        extraRules = [
          (netns-exec.sudoRule // { users = [ config.central.username ]; })
        ];
        extraConfig = netns-exec.sudoEnvKeep;
      };

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
              ${procps}/bin/pkill -F ${tp.pidFile}
            '';
        };
      };
    }
  );
}
