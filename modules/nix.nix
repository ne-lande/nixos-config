{ config, lib, ... }:
with lib;
{
  options.nix-configuration = {
    enable = mkEnableOption "enable nix-configuration";
  };

  config = mkIf config.nix-configuration.enable {
    nix = {
      channel.enable = false;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/nix-config";
    };
  };
}
