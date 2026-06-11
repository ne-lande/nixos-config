{ config, lib, pkgs, ... }:
let
  username = config.central.username;

  # Zoom's Qt Wayland backend is slow and falls back to software rendering,
  # causing severe lag in settings. Force XCB so it uses XWayland + GL.
  zoom-xcb = pkgs.symlinkJoin {
    name = "zoom-us";
    paths = [ pkgs.zoom-us ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in $out/bin/zoom $out/bin/zoom-us; do
        [ -f "$bin" ] && wrapProgram "$bin" --set QT_QPA_PLATFORM xcb
      done
    '';
  };
in
with lib;
{
  options.apps.zoom = {
    enable = mkEnableOption "enable zoom";
  };

  config = mkIf config.apps.zoom.enable {
    environment.systemPackages = [ zoom-xcb ];

    home-manager.users.${username} = { ... }: {
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/zoommtg" = "Zoom.desktop";
      };
    };
  };
}
