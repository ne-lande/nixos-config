{
  config,
  lib,
  ...
}:
let
  username = config.central.username;
  vesktop = "/etc/profiles/per-user/${username}/bin/vesktop";
in
with lib;
{
  options.apps.vesktop = {
    enable = mkEnableOption "enable vesktop";
  };

  config = mkIf config.apps.vesktop.enable {
    home-manager.users.${username} =
      { ... }:
      {
        xdg.desktopEntries = {
          vesktop-zapret-netns = {
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
            exec = "zapret-run ${vesktop}";
            genericName = "Internet Messenger";
            icon = "vesktop";
            name = "Vesktop [ZAPRET]";
            noDisplay = false;
            startupNotify = true;
            terminal = false;
            type = "Application";
            mimeType = [ "x-scheme-handler/discord" ];
            settings = {

            };
          };
          vesktop-zapret2-netns = {
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
            exec = "zapret2-run ${vesktop}";
            genericName = "Internet Messenger";
            icon = "vesktop";
            name = "Vesktop [ZAPRET2]";
            noDisplay = false;
            startupNotify = true;
            terminal = false;
            type = "Application";
            mimeType = [ "x-scheme-handler/discord" ];
            settings = { };
          };
          vesktop-awg-netns = {
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
            exec = "awg-run ${vesktop}";
            genericName = "Internet Messenger";
            icon = "vesktop";
            name = "Vesktop [AWG]";
            noDisplay = false;
            startupNotify = true;
            terminal = false;
            type = "Application";
            mimeType = [ "x-scheme-handler/discord" ];
            settings = {

            };
          };
        };

        programs.vesktop = {
          enable = true;
          settings = {
            appBadge = false;
            arRPC = true;
            checkUpdates = false;
            customTitleBar = false;
            disableMinSize = true;
            minimizeToTray = false;
            tray = true;
            splashBackground = "#000000";
            splashColor = "#ffffff";
            splashTheming = true;
            staticTitle = true;
            hardwareAcceleration = true;
            discordBranch = "stable";
          };
          vencord = {
            settings = {
              frameless = false;
              transparent = false;
              autoUpdate = true;
              autoUpdateNotification = true;
              notifyAboutUpdates = true;
              useQuickCss = true;
              disableMinSize = true;
              winNativeTitleBar = false;
              winCtrlQ = false;
              themeLinks = [
                "https://refact0r.github.io/system24/build/system24.css"
              ];
              plugins = {
                NoTrack = {
                  enabled = true;
                  disableAnalytics = true;
                };
                WebContextMenus = {
                  enabled = true;
                  addBack = true;
                };
                Settings = {
                  enabled = true;
                  settingsLocation = "aboveNitro";
                };
                SupportHelper.enabled = true;
                FakeNitro.enabled = true;
              };
            };
          };
        };
      };
  };
}
