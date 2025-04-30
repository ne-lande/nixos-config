{ config, lib, pkgs, types, ... }:
let
  username = config.central.username;
in with lib;
{
  options.apps.librewolf = {
    enable = mkEnableOption "enable docker";
  };

  config = mkIf config.apps.librewolf.enable {
    home-manager.users.${username} = { ... }: {
      programs.librewolf = {
        enable = true;
        # Enable WebGL, cookies and history
        settings = {
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "webgl.disabled" = false;
            "privacy.resistFingerprinting" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "network.cookie.lifetimePolicy" = 100;
            "identity.fxaccounts.enabled" = true;
        };
      };
    };

    xdg.mime.defaultApplications = {
      # "application/xhtml+xml" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      # "text/html" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      # "text/xml" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      # "x-scheme-handler/ftp" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      # "x-scheme-handler/http" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      # "x-scheme-handler/https" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "text/html" = "librewolf.desktop";
      "text/xml" = "librewolf.desktop";
      "x-scheme-handler/ftp" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };
  };
}
