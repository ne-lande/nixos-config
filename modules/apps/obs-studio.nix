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
  options.apps.obs-studio = {
    enable = mkEnableOption "enable obs-studio";
  };

  config = mkIf config.apps.obs-studio.enable {
    # Virtual camera support
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';

    home-manager.users.${username} =
      { ... }:
      {
        programs.obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-pipewire-audio-capture # per-app PipeWire audio sources
            wlrobs                     # Wayland screen capture (niri/wlroots)
            obs-vaapi                  # hardware video encoding
            obs-vkcapture              # Vulkan/OpenGL game capture
          ];
        };
      };
  };
}
