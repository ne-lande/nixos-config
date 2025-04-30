{ config, lib, pkgs, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.x86_64-linux;
  username = config.central.username;
in with lib;
{
  options.apps.spicetify = {
    enable = mkEnableOption "enable spotify with tweaks";
  };

  config = mkIf config.apps.spicetify.enable {
    home-manager.users.${username} = { ... }: {
      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.text;
        colorScheme = "Spotify";

        enabledExtensions = with spicePkgs.extensions; [
          fullAppDisplay
          shuffle
          hidePodcasts
        ];
      };
    };
  };
}
