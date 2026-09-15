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
        # Keep nix-direnv dev shells alive across `nh clean` GC runs.
        keep-outputs = true;
      };
      # Scheduled dedup instead of auto-optimise-store, which hardlink-scans
      # on every store write and slows all builds.
      optimise.automatic = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/nix-config";
    };
  };
}
