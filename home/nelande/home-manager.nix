{ spicetify-nix, ... } :{ config, pkgs, ... }: {
  imports = [
    (import ./homemanager/bundle.nix {inherit spicetify-nix;})
  ];

  home = {
    username = "nelande";
    homeDirectory = "/home/nelande";

    # desktop
    # work-related desktop
    # non-mandatory cli tools
    # work-specific cli
    packages = with pkgs; [
      telegram-desktop
      libreoffice-still
      obsidian
      vesktop
      teamspeak_client
      prismlauncher
      ungoogled-chromium
      francis
      kitty
      gimp
      vlc
    ] ++ [
      jetbrains.idea-community-bin
      zed-editor
      burpsuite
      wireshark
      cyberchef
      insomnia
    ] ++ [
      tldr
      eza
      fd
      ripgrep
      jq
      glow
      bat
      cloc
    ] ++ [
      nmap
      swaks
      nuclei
      katana
      sqlmap
      feroxbuster
    ];

    stateVersion = "23.11"; # dont

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
