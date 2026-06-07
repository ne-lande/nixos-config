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
  options.apps.librewolf = {
    enable = mkEnableOption "enable librewolf";
  };

  config = mkIf config.apps.librewolf.enable {
    home-manager.users.${username} = { ... }: {
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
          # Updates & Background Services
          AppAutoUpdate                 = false;
          BackgroundAppUpdate           = false;

          # Feature Disabling
          DisableBuiltinPDFViewer       = true;
          DisableFirefoxStudies         = true;
          DisableFirefoxAccounts        = true;
          DisableFirefoxScreenshots     = true;
          DisableForgetButton           = true;
          DisableMasterPasswordCreation = true;
          DisableProfileImport          = true;
          DisableProfileRefresh         = true;
          DisableSetDesktopBackground   = true;
          DisablePocket                 = true;
          DisableTelemetry              = true;
          DisableFormHistory            = true;
          DisablePasswordReveal         = true;

          # Access Restrictions
          BlockAboutConfig              = true;
          BlockAboutProfiles            = true;
          BlockAboutSupport             = true;

          # UI and Behavior
          DisplayMenuBar                = "never";
          DontCheckDefaultBrowser       = true;
          HardwareAcceleration          = true;
          OfferToSaveLogins             = false;
          #DefaultDownloadDirectory      = "${home}/Downloads";

          ExtensionSettings =
          let
            moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
          in
          {
            "*".installation_mode = "blocked";

            "uBlock0@raymondhill.net" = {
              default_area = "menupanel";
              install_url = moz "ublock-origin";
              installation_mode = "force_installed";
              updates_disabled = true;
              private_browsing = true;
            };
            # bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              default_area = "menupanel";
              install_url = moz "bitwarden-password-manager";
              installation_mode = "force_installed";
              updates_disabled = true;
              private_browsing = true;
            };
            "CanvasBlocker@kkapsner.de" = {
              default_area = "menupanel";
              install_url = moz "canvasblocker";
              installation_mode = "force_installed";
              updates_disabled = true;
              private_browsing = true;
            };
            "foxyproxy@eric.h.jung" = {
              default_area = "menupanel";
              install_url = moz "foxyproxy-standard";
              installation_mode = "force_installed";
              updates_disabled = true;
              private_browsing = true;
            };
          };

          "3rdparty".Extensions = {
            "uBlock0@raymondhill.net".adminSettings = {
              userSettings = rec {
                uiTheme            = "dark";
                uiAccentCustom     = true;
                uiAccentCustom0    = "#8300ff";
                cloudStorageEnabled = mkForce false;

                importedLists = [
                  "https://filters.adtidy.org/extension/ublock/filters/3.txt"
                  "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
                ];

                externalLists = lib.concatStringsSep "\n" importedLists;
              };

              selectedFilterLists = [
                "CZE-0"
                "adguard-generic"
                "adguard-annoyance"
                "adguard-social"
                "adguard-spyware-url"
                "easylist"
                "easyprivacy"
                "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
                "plowe-0"
                "ublock-abuse"
                "ublock-badware"
                "ublock-filters"
                "ublock-privacy"
                "ublock-quick-fixes"
                "ublock-unbreak"
                "urlhaus-1"
              ];
            };
          };
        };
        profiles.default = {
          search = {
            force = true;
            default = "google";
            privateDefault = "duckduckgo";
            engines = {
            "google" = {
              urls = [
                {
                  template = "https://www.google.com/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }
              ];
            };
            "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      { name = "channel"; value = "unstable"; }
                      { name = "query";   value = "{searchTerms}"; }
                    ];
                  }
                ];
                icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
            "Nix Options" = {
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      { name = "channel"; value = "unstable"; }
                       { name = "query";   value = "{searchTerms}"; }
                    ];
                  }
                ];
                icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };
            "NixOS Wiki" = {
                urls = [
                  {
                    template = "https://wiki.nixos.org/w/index.php";
                    params = [
                      { name = "search"; value = "{searchTerms}"; }
                    ];
                  }
                ];
                icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nw" ];
              };
          };
          };
          containersForce = true;
          containers = {
            #zapret = {
            #  color = "blue";
            #  icon = "circle";
            #  id = 1;
            #};
            #awg = {
            #  color = "red";
            #  icon = "fence";
            #  id = 2;
            #};
            #burp = {
            #  color = "orange";
            #  icon = "briefcase";
            #  id = 3;
            #};
          };
          settings = {
            "extensions.autoDisableScopes" = 0;
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
