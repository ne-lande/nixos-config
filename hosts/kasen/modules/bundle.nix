{ ... }: {
  imports = [
    ./boot.nix
    ./sound.nix
    ./nvidia.nix
    ./network.nix
  ];
}
