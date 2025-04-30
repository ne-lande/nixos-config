{ config, ...}:
{
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager.enable = true;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp6s0";
    };

    # allow any traffic on intranet
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" "enp6s0" ];
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
}
