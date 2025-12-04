{ pkgs, ... }:
let
  username = "honeset";
in
{
  central = {
    username = username;
  };

  home-manager.users.${username} =
    { ... }:
    {
      home = {
        username = username;
        homeDirectory = "/home/${username}";

        packages = with pkgs; [
          # Cli day-to-day
          tldr
          eza
          fd
          ripgrep
          jq
          glow
          bat
          cloc
        ];

        # DONT CHANGE ME!
        stateVersion = "24.11";
      };
    };
}
