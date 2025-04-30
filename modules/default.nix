{ lib, ... }: {
  imports = [
    ./central.nix
    ./docker.nix
    ./ssh.nix
    ./git.nix
    ./neovim.nix
    ./virt-manager.nix
    ./shell
    ./DE/gnome
    ./DE/plasma
    ./apps
  ];
}
