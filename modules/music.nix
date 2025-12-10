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
  options.music = {
    enable = mkEnableOption "enable music";
    musicDirectory = mkOption {
      type = types.str;
      default = "/stor/Music";
      description = "The directory where music is stored.";
    };
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The address of the MPD server.";
    };
    port = mkOption {
      type = types.int;
      default = 6600;
      description = "The port of the MPD server.";
    };
  };

  config = mkIf config.music.enable {
    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/1000"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
    };

    services.mpd = {
      enable = true;
      user = username;
      group = "audio";
      musicDirectory = config.music.musicDirectory;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "My PipeWire Output"
        }
      '';
      network = {
        listenAddress = config.music.address;
        port = config.music.port;
      };
    };

    home-manager.users.${username} =
      { ... }:
      {
        programs.cava.enable = true;

        programs.rmpc = {
          enable = true;
          package = pkgs.rmpc;
        };
      };
  };
}
