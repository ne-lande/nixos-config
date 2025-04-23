{ pkgs, ... }: {
 nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
 };

  environment.systemPackages = with pkgs; [
    home-manager
    vesktop
    telegram-desktop
    obsidian
    librewolf
    cloc
    insomnia
    unixtools.xxd
    unixtools.top
    unixtools.route
    unixtools.ping
    unixtools.netstat
    unixtools.ifconfig
    libreoffice-still
    prismlauncher
    openssl
    dos2unix
    zed-editor
    dig
    gnumake
    file
    kitty
    bat
    btop
    gcc
    killall
    wget
    zip
    git
    eza
    neovim
    fd
    glow
    htop
    jq
    ripgrep
    tree
    unrar
    unzip
    starship
    jetbrains.idea-community
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
