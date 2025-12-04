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
        obsidian
        kitty
        vlc
      ] ++ [
        # Work-related
        wireshark
      ] ++ [
        # Cli day-to-day
        eza
        fd
        ripgrep
        jq
        bat
        cloc
      ] ++ [
        # Work-specific
        nmap
        nuclei
        katana
        sqlmap
        feroxbuster
      ];

      # SET ME stateVersion = "";
    };
  };
}
