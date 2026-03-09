{ inputs, ... }:
{
  networking = {
    hostName = "abashed";
    networkmanager.enable = true;

    # allow any traffic on intranet
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" ];
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

  };

  services.zerotierone = {
    enable = true;
    joinNetworks = inputs.secrets.zerotierNetworks;
  };
}
