{
  config,
  lib,
  ...
}:
let
  username = config.central.username;
  nixpath = "/run/current-system/sw/bin";
  homepath = "/etc/profiles/per-user/${username}/bin";
in
with lib;
{
  options.apps.vesktop = {
    enable = mkEnableOption "enable vesktop";
  };

  config = mkIf config.apps.vesktop.enable {
    security.sudo.extraConfig = ''
      ALL ALL=(ALL) NOPASSWD:SETENV: ${nixpath}/ip netns exec wg sudo -u ${username} -E ${homepath}/vesktop --ozone-platform=wayland
    '';

    home-manager.users.${username} =
      { ... }:
      {
        xdg.desktopEntries.vesktop-netns = {
          categories = [
            "Network"
            "InstantMessaging"
            "Chat"
          ];
          exec = ''sudo -E ${nixpath}/ip netns exec wg sudo -u ${username} -E ${homepath}/vesktop --ozone-platform=wayland'';
          genericName = "Internet Messenger";
          icon = "vesktop";
          name = "Vesktop [NETNS]";
          noDisplay = false;
          startupNotify = true;
          terminal = false;
          type = "Application";
          mimeType = [ "x-scheme-handler/discord" ];
          settings = {

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
            tray = false;
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
              autoUpdate = false;
              autoUpdateNotification = false;
              notifyAboutUpdates = false;
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
