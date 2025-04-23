{ ... }: {
  networking = {
    enableIPv6 = true;
    hostName = "yuka";
    networkmanager.enable = true;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "wlp0s20f3";
    };
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 9993 ];
  };
}
