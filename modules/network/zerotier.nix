{
  config,
  lib,
  inputs,
  ...
}:
let
  networks = inputs.secrets.zerotierNetworks;
in
with lib;
{
  options.network.zerotier = {
    enable = mkEnableOption "enable zerotier";
    trustedInterfaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "ZeroTier network interfaces to trust in the firewall.";
    };
  };

  config = mkIf config.network.zerotier.enable {
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = config.network.zerotier.trustedInterfaces;
    };

    services.zerotierone = {
      enable = true;
      joinNetworks = networks;
    };
  };
}
