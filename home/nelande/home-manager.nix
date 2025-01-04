{ spicetify-nix, ... } :{ config, ... }: {
  imports = [
    (import ./homemanager/bundle.nix {inherit spicetify-nix;})
  ];

  home = {
    username = "nelande";
    homeDirectory = "/home/nelande";
    stateVersion = "23.11";

    # I store my files in different non crypted module so i can nonpainfuly extract them
    #file = {
    #   "Videos".source = config.lib.file.mkOutOfStoreSymlink /stor/Videos;
    #   "Documents".source = config.lib.file.mkOutOfStoreSymlink /stor/Documents;
    #   "Music".source = config.lib.file.mkOutOfStoreSymlink /stor/Music;
    #   "Pictures".source = config.lib.file.mkOutOfStoreSymlink /stor/Pictures;
    #   "Code".source = config.lib.file.mkOutOfStoreSymlink /stor/Code;
    #   "Downloads".source = config.lib.file.mkOutOfStoreSymlink /stor/Downloads;
    #};
  };
}
