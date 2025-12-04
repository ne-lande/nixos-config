{ pkgs, ... }: {
 nixpkgs.config = {
    allowUnfree = false;
    allowBroken = false;
    allowInsecure = false;
    allowUnsupportedSystem = false;
 };

  environment.systemPackages = with pkgs; [
    home-manager
    telegram-desktop
    obsidian
    cloc
    insomnia
    unixtools.xxd
    unixtools.top
    unixtools.route
    unixtools.ping
    unixtools.netstat
    unixtools.ifconfig
    openssl
    dos2unix
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
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
