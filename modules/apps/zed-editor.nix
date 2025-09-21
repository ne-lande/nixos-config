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
          extraPackages = with pkgs; [
            nixd
            package-version-server
            terraform-ls
            pyright
          ];

          enable = true;
          extensions = [
            "nix" "java" "ruby" "dart" "php" "html" "proto"
            "toml" "make" "docker-compose" "dockerfile" "terraform"
            "0x96f"
          ];

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

              languages = {
                  "Nix" = {
                      language_servers = ["!nil" "nixd"];
                  };
                  Python = {
                    language_servers = [
                      "pyright"
                    ];
                    format_on_save = "on";
                  };
              };

              vim_mode = false;
              load_direnv = "shell_hook";
              base_keymap = "VSCode";
              theme = {
                  mode = "system";
                  light = "One Light";
                  dark = "0x96f Theme";
              };

              show_whitespaces = "selection";
              ui_font_size = 16;
              buffer_font_size = 16;
          };
      };
    };
  };
}
