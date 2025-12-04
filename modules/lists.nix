{
  pkgs,
  lib,
  config,
  ...
}:
# These are packages without configuration and installed as packages
let
  username = config.central.username;
  packages = with pkgs; {
    apps-base = [
      telegram-desktop
      libreoffice-still
      teamspeak6-client
      prismlauncher
      obsidian
      kdePackages.francis
      gimp
      mpv
    ];

    apps-work = [
      wireshark
      cyberchef
      #caido
      imhex
      ghidra
    ];

    cli-work = [
      nmap
      swaks
      nuclei
      katana
      sqlmap
      feroxbuster
    ];

    cli-net = [
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
      traceroute
      tcpdump
    ];

    cli-misc = [
      unixtools.top
      unixtools.xxd
      p7zip
      zip
      unzip
      unrar
      jq
    ];

    cli-base = [
      btop
      git
      gcc
      cmake
      gnumake
      file
      tldr
      eza
      fd
      ripgrep
      bat
      cloc
    ];
  };
in
{

  options.lists = with lib; {
    enable = mkEnableOption "Enable package lists";
  };

  config =
    with lib;
    mkIf config.lists.enable {
      home-manager.users.${username} =
        { ... }:
        {
          home.packages =
            packages.apps-base
            ++ packages.apps-work
            ++ packages.cli-work
            ++ packages.cli-net
            ++ packages.cli-misc
            ++ packages.cli-base;
        };
    };
}
