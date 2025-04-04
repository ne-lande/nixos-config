{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  environment.systemPackages = with pkgs; [
    home-manager
    xdg-utils
    unixtools.ifconfig
    unixtools.netstat
    unixtools.route
    unixtools.ping
    unixtools.xxd
    unixtools.top
    dos2unix
    wireguard-tools
    openvpn
    openssl
    openssh
    dig
    file
    btop
    htop
    gnumake
    cmake
    gcc
    killall
    neofetch
    wget
    git
    tree
    tmux
    zip
    unrar
    unzip
    p7zip
  ];

  fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      comic-mono
  ];
}
