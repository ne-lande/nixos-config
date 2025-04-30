{ lib, config, ... }:
let
  username = config.central.username;
in with lib;
{
  options.shell.starship = {
    enable = mkEnableOption "enable starship";
  };

  config = mkIf config.shell.starship.enable {
    home-manager.users.${username} = { ... }: {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
            add_newline = true;
            command_timeout = 1300;
            scan_timeout = 50;
            format = "$all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
        };
      };
    };
  };
}
