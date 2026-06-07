{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  system = "x86_64-linux";

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
      prismlauncher
      kdePackages.francis
      gimp
      claude-code
      insomnia
    ];

    apps-work = [
      wireshark
      cyberchef
      imhex
      inputs.bpf.packages.${system}.burpsuitepro
      inputs.ipoc.packages.${system}.idapro
      zoom-us
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
      fastfetch
      unixtools.top
      unixtools.xxd
      p7zip
      zip
      unzip
      unrar
      jq
      glow
      htop
      dos2unix
      psmisc
    ];

    cli-base = [
      tree
      btop
      git
      just
      gnumake
      gcc
      file
      tldr
      cloc
      bat
      eza
      fd
      ripgrep
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
