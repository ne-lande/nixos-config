{ spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.x86_64-linux;
in
{
  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModules.default ];

  # configure spicetify :)
  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "Spotify";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
      ];
    };
}
