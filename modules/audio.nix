{
  config,
  lib,
  ...
}:
with lib;
{
  options.audio = {
    enable = mkEnableOption "pipewire audio stack";
  };

  config = mkIf config.audio.enable {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # Realtime scheduling for pipewire clients
    security.rtkit.enable = true;
  };
}
