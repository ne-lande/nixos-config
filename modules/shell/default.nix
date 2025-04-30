{ lib, ... }: {
  imports = [
    ./tmux.nix
    ./zsh.nix
    ./starship.nix
  ];
}
