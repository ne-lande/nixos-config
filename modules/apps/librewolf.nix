{
  config,
  lib,
  ...
}:
let
  username = config.central.username;
in
with lib;
{
  options.apps.librewolf = {
    enable = mkEnableOption "enable librewolf";
  };

  config = mkIf config.apps.librewolf.enable {
    home-manager.users.${username} =
      { ... }:
      {
        programs.librewolf = {
          enable = true;
          settings = {
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "webgl.disabled" = false;
            "privacy.resistFingerprinting" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "network.cookie.lifetimePolicy" = 100;
            "identity.fxaccounts.enabled" = false;
          };
          policies = {
            BlockAboutConfig = true;
            DefaultDownloadDirectory = "\${home}/Downloads";
            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                default_area = "menupanel";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
              "Bitwarden" = {
                default_area = "menupanel";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
              "CanvasBlocker" = {
                default_area = "menupanel";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
              "FoxyProxy" = {
                default_area = "menupanel";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
              "Sidebery" = {
                default_area = "menupanel";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
                installation_mode = "force_installed";
                private_browsing = true;
              };
            };
          };
        };
      };

    xdg.mime.defaultApplications = {
      "application/xhtml+xml" = "librewolf.desktop";
      "text/html" = "librewolf.desktop";
      "text/xml" = "librewolf.desktop";
      "x-scheme-handler/ftp" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };

    ## Add autoinstall extensions?
    # FoxyProxy with not so secret configuration, maybe fetch list from geoip block
    # Bitwarden with no config (auth on place)
    # Simple Translation with config?
  };
}
