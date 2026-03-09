{
  config,
  lib,
  inputs,
  ...
}:
let
  #networks = config.secrets.zerotier.networks;
  networks = inputs.secrets.zerotierNetworks;
in
with lib;
{
  options.network.zerotier = {
    enable = mkEnableOption "enable zerotier";
  };

  config = mkIf config.network.zerotier.enable {
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [
        "ztwfupmdli"
      ];
    };

    services.zerotierone = {
      enable = true;
      joinNetworks = networks;
    };
  };
}
