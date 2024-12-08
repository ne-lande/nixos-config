{ ... }: {
  imports = [
    ./user.nix
    ./gpg.nix
    ./xdg.nix
    ./xserver.nix
  ];
}
