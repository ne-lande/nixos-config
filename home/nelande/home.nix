{ config, pkgs, ... }:
let
  username = "nelande";
in
{
  central = {
    username = username;
  };

  home-manager.users.${username} = { ... }: {
    home = {
      username = username;
      homeDirectory = "/home/${username}";

      packages = with pkgs; [
        # Desktop day-to-day
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
        # Work-related
        jetbrains.idea-community-bin
        burpsuite
        wireshark
        cyberchef
        insomnia
      ] ++ [
        # Cli day-to-day
        tldr
        eza
        fd
        ripgrep
        jq
        glow
        bat
        cloc
      ] ++ [
        # Work-specific
        nmap
        swaks
        nuclei
        katana
        sqlmap
        feroxbuster
      ];

      # DONT CHANGE ME!
      stateVersion = "23.11";
    };
  };
}
