{ lib, ... }: {
  imports = [
    ./kitty.nix
    ./librewolf.nix
    ./steam.nix
    ./spicetify.nix
    ./zed-editor.nix
  ];
}
