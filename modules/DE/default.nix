{ ... }:
{
  #imports = mylib.scanPaths ./.;
  imports = [
    ./gnome.nix
    ./plasma.nix
  ];
}
