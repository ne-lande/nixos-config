{ config, lib, pkgs, ... }:
let
  username = config.central.username;
in with lib;
{
  options.apps.zed-editor = {
    enable = mkEnableOption "enable zed editor";
    background_image = mkOption { type = types.str; };
  };

  config = lib.mkIf config.apps.zed-editor.enable {
    home-manager.users.${username} = { ... }: {
      programs.zed-editor = {
          enable = true;
          extensions = ["nix" "php" "toml" "make" "docker-compose" "dockerfile"];

          userSettings = {
              assistant.enabled = false;

              node = {
                  path = lib.getExe pkgs.nodejs;
                  npm_path = lib.getExe' pkgs.nodejs "npm";
              };

              hour_format = "hour24";
              auto_update = false;
              terminal = {
                  alternate_scroll = "off";
                  blinking = "off";
                  copy_on_select = false;
                  dock = "right";
                  detect_venv = {
                      on = {
                          directories = [".env" "env" ".venv" "venv"];
                          activate_script = "default";
                      };
                  };
                  env = {
                      TERM = "xterm-kitty";
                  };
                  font_family = "FiraCode Nerd Font";
                  font_features = null;
                  font_size = null;
                  line_height = "comfortable";
                  option_as_meta = false;
                  button = false;
                  shell = "system";
                  toolbar = {
                      title = true;
                  };
                  working_directory = "current_project_directory";
              };

              lsp = {
                  nix = {
                      binary = {
                          path_lookup = true;
                      };
                  };
              };

              vim_mode = false;
              load_direnv = "shell_hook";
              base_keymap = "VSCode";
              theme = {
                  mode = "system";
                  light = "One Light";
                  dark = "One Dark";
              };

              show_whitespaces = "selection";
              ui_font_size = 16;
              buffer_font_size = 16;
          };
      };
    };
  };
}
