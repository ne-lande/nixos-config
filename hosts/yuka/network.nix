{ config, ...}: {
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager.enable = true;

    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" ];
    };
  };
}
