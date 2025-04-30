{ config, lib, pkgs, types, ... }:
let
  wallpaper = config.central.plasma-wallpaper;
  username = config.central.username;
in with lib;
{
  options.DE.plasma = {
    enable = mkEnableOption "enable plasma with manager";
  };

  config = mkIf config.DE.plasma.enable {
    services.xserver.enable = true;

        # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

        # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us,ru";
      variant = "";
    };

        # Enable and configure autologin
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = username;
    services.displayManager.defaultSession = "plasmax11"; # plasma for wayland

    home-manager.users.${username} = { ... }: {
      programs.plasma = {
        enable = true;
        overrideConfig = true;

        workspace = {
          enableMiddleClickPaste = false;
          clickItemTo = "select";
          lookAndFeel = "org.kde.breezedark.desktop";
          cursor.theme = "Breeze-Light";
          iconTheme = "breeze-dark";
          wallpaper = wallpaper;
        };

        kscreenlocker = {
          autoLock = null;
          lockOnStartup = false;
          lockOnResume = false;
          timeout = null;
        };

        hotkeys.commands."launch-kitty" = {
          name = "Launch Kitty";
          key = "Meta+Alt+K";
          command = "kitty";
        };

        panels = [
          # Windows-like panel at the bottom
          {
            height = 60;
            hiding = "normalpanel";
            floating = true;
            location = "bottom";
            widgets = [
              "org.kde.plasma.kickoff"
              "org.kde.plasma.icontasks"
              "org.kde.plasma.marginsseperator"
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
            ];
            screen = 0;
          }
        ];

        spectacle = {
            shortcuts = {
            captureActiveWindow = "";
            captureCurrentMonitor = "";
            captureEntireDesktop = "";
            captureRectangularRegion = "Print";
            captureWindowUnderCursor = "";
            launchWithoutCapturing = "";
            launch = "";
            };
        };

        shortcuts = {
            ksmserver = {
            "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
            };

            "KDE Keyboard Layout Switcher" = {
            "Switch to Last-Used Keyboard Layout"="";
            "Switch to Next Keyboard Layout"="Shift+Alt";
            };

            kwin = {
            "Expose" = "Meta+,";
            "Switch Window Down" = "Meta+J";
            "Switch Window Left" = "Meta+H";
            "Switch Window Right" = "Meta+L";
            "Switch Window Up" = "Meta+K";
            "Zoom In" = "";
            "Zoom Out" = "";
            "Activate Window Demanding Attention" = "";
            };

            "plasmashell" = {
            # Some setting are set by root configuration so we need to override that
            "next activity" = "none";
            "previous activity" = "none";
            };
        };

        configFile = {
            "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
            "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
            "kwinrc"."ElectricBorders" = {
                "TopLeft"="None";
                "Top"="KRunner";
            };
            "kwinrc"."Desktops"."Number" = {
            value = 1;
            # Forces kde to not change this value (even through the settings app).
            immutable = true;
            };
        };
      };
    };
  };
}
