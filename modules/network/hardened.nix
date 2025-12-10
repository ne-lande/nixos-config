{ config, lib, ... }:
with lib;
{
  options.network.hardened = {
    enable = mkEnableOption "enable zerotier";
  };

  config = mkIf config.network.hardened.enable {
    networking = {
      enableIPv6 = true;
      hostName = hostname;
      networkmanager = {
        enable = true;
      };

      nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };
}
