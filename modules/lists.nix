{
  pkgs,
  lib,
  config,
  ...
}:
let
  packages = with pkgs; {
    fonts = [
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.fira-code
      comic-mono
      mplus-outline-fonts.githubRelease
    ];

    apps-base = [
      telegram-desktop
      libreoffice-still
      teamspeak6-client
      prismlauncher
      kdePackages.francis
      gimp
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
      wget
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
      neofetch
      unixtools.top
      unixtools.xxd
      p7zip
      zip
      unzip
      unrar
      jq
    ];

    cli-base = [
      tree
      file
      btop
      git
      just
      gnumake
      file
      tldr
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
      nixpkgs.config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = false;
        allowUnsupportedSystem = true;
      };

      fonts.packages = packages.fonts;

      environment.systemPackages =
        packages.apps-base
        ++ packages.apps-work
        ++ packages.cli-work
        ++ packages.cli-net
        ++ packages.cli-misc
        ++ packages.cli-base;
    };
}
