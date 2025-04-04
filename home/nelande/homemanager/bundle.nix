{ spicetify-nix, ... }: {
  imports = [
    ./plasma-manager.nix
    ./zsh.nix
    ./kitty.nix
    ./neovim.nix
    ./librewolf.nix
    ./starship.nix
    (import ./spicetify.nix {inherit spicetify-nix;})
  ];
}
