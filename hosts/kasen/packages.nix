{ pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      # * Utilities
      home-manager
      xdg-utils
      dos2unix
      file
      btop
      htop
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
    ]
    ++ [
      # Network utilities
      mtr
      dig
      wireguard-tools
      openvpn
      openssl
      openssh
      unixtools.ifconfig
      unixtools.netstat
      unixtools.route
      unixtools.ping
      unixtools.xxd
      unixtools.top
      traceroute
      tcpdump
    ]
    ++ [
      # Build essentials
      gcc
      cmake
      gnumake
    ];

  fonts.packages = with pkgs; [
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    comic-mono
  ];
}
