{ config, lib, ... }:
let
  username = config.central.username;
in
with lib;
{
  options.apps.obsidian = {
    enable = mkEnableOption "enable obsidian";
  };

  config = mkIf config.apps.obsidian.enable {
    home-manager.users.${username} =
      { ... }:
      {
        programs.obsidian = {
          enable = true;
          defaultSettings = {
            app = {

            };
            communityPlugins = [

            ];
            corePlugins = [

            ];
          };
        };
      };
  };
}
