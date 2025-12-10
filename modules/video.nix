{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.central.username;
in
with lib;
{
  options.video = {
    enable = mkEnableOption "enable video";
  };

  config = mkIf config.video.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];

    home-manager.users.${username} =
      { ... }:
      {
        programs.mpv = {
          enable = true;
          bindings = { };
          config = { };

        };
      };
  };
}
