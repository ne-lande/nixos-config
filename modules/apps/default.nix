{ ... }:
{
  #imports = mylib.scanPaths ./.;
  imports = [
    ./kitty.nix
    ./librewolf.nix
    #"./lwchrome.nix"
    #"./obs-studio.nix"
    ./obsidian.nix
    ./steam.nix
    ./vesktop.nix
    ./zed-editor.nix
  ];
}
