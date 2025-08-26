{ config, pkgs, ...}: {
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager.enable = true;

    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" ];
    };
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
      NetworkNamespacePath = "/var/run/netns/wg";
      ExecStart = with pkgs; writers.writeBash "wg-up" ''
        set -e
        ${iproute2}/bin/ip link add nsawg type amneziawg
        ${iproute2}/bin/ip link set nsawg netns wg
        ${iproute2}/bin/ip -n wg address add 10.8.0.7/24 dev nsawg
        ${iproute2}/bin/ip netns exec wg \
          ${wireguard-tools}/bin/awg setconf nsawg /home/nelande/lande.conf
        ${iproute2}/bin/ip -n wg link set nsawg up
        ${iproute2}/bin/ip -n wg route add default dev nsawg
      '';
      ExecStop = with pkgs; writers.writeBash "wg-down" ''
        ${iproute2}/bin/ip -n wg route del default dev nsawg
        ${iproute2}/bin/ip -n wg link del nsawg
      '';
    };
  };
}
