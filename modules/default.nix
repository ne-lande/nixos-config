{ ... }:
{
  imports = [
    ./central.nix
    ./docker.nix
    ./ssh.nix
    ./git.nix
    ./neovim.nix
    ./virt-manager.nix
    ./fish.nix
    ./DE/gnome
    ./DE/plasma
    ./apps
    ./lists.nix
  ];
}
