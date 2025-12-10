{ config, ... }:
{
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager = {
      enable = true;
    };

    firewall.trustedInterfaces = [
      "enp6s0"
    ];

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  network.zerotier.enable = true;
  network.awg.enable = true;
}
