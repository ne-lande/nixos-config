{ config, lib, pkgs, ... }:
with lib;
{
  # Yep, this is the place
  options.secrets = {
    zerotier.networks = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    ssh.public-keys = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
}
