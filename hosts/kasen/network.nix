{ config, pkgs, ... }:
{
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager = {
      enable = true;
    };

    # allow any traffic on intranet
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [
        "ztwfupmdli"
        "enp6s0"
      ];
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = config.secrets.zerotier.networks;
  };

  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart =
        with pkgs;
        writers.writeBash "wg-up" ''
          set -e

          # Set tun to default ns
          ${iproute2}/bin/ip link add wg-tun-0 type veth peer name wg-tun-1
          ${iproute2}/bin/ip link set wg-tun-1 netns wg
          ${iproute2}/bin/ip addr add 10.0.0.1/24 dev wg-tun-0
          ${iproute2}/bin/ip link set dev wg-tun-0 up
          ${iproute2}/bin/ip -n wg addr add 10.0.0.2/24 dev wg-tun-1
          ${iproute2}/bin/ip -n wg link set dev wg-tun-1 up

          # Create AWG tun
          ${iproute2}/bin/ip link add wg0 type amneziawg
          ${iproute2}/bin/ip link set wg0 netns wg
          ${iproute2}/bin/ip -n wg address add 10.8.0.23/24 dev wg0
          ${iproute2}/bin/ip netns exec wg ${amneziawg-tools}/bin/awg setconf wg0 /home/nelande/lande.conf
          ${iproute2}/bin/ip -n wg link set wg0 up
          ${iproute2}/bin/ip -n wg route add default dev wg0

          # Create proxy
          ${iproute2}/bin/ip netns exec wg ${tinyproxy}/bin/tinyproxy -c /home/nelande/tinyproxy.conf
        '';
      ExecStopPost =
        with pkgs;
        writers.writeBash "wg-down" ''
          # Remove tun
          ${iproute2}/bin/ip link del wg-tun-0

          # Remove awg links
          ${iproute2}/bin/ip -n wg route del default dev wg0
          ${iproute2}/bin/ip -n wg link del wg0

          # Kill tinyproxy
          ${procps}/bin/pkill -F /tmp/wg-tinyproxy.pid
        '';
    };
  };
}
