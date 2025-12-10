{
  config,
  lib,
  pkgs,
  ...
}:
let
  wallpaper = config.central.plasma-wallpaper;
  username = config.central.username;
in
with lib;
{
  options.DE.plasma = {
    enable = mkEnableOption "enable plasma with manager";
  };

  config = mkIf config.DE.plasma.enable {
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      konsole
      kate
    ];

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us,ru";
      variant = "";
    };

    # Enable and configure autologin
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = username;
    services.displayManager.defaultSession = "plasma"; # plasma for wayland

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    };

    home-manager.users.${username} =
      { ... }:
      {
        programs.konsole.enable = false;
        programs.kate.enable = false;
        programs.ghostwriter.enable = false;
        programs.elisa.enable = false;
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

          fonts = {
            fixedWidth = {
              family = "Fantasque Sans Mono";
              pointSize = 12;
            };
            general = {
              family = "Fantasque Sans Mono";
              pointSize = 12;
            };
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
            command = "kitten quick-access-terminal";
          };

          panels = [
            # Windows-like panel at the bottom
            {
              height = 50;
              alignment = "center";
              hiding = "normalpanel";
              floating = true;
              location = "top";
              widgets = [
                {
                  kickoff = {
                    icon = "start-here-kde-symbolic";
                    label = null;
                    sortAlphabetically = true;
                    compactDisplayStyle = true;
                    sidebarPosition = "left";
                    favoritesDisplayMode = "grid";
                    applicationsDisplayMode = "grid";
                    showButtonsFor = "power";
                    showActionButtonCaptions = true;
                    popupHeight = 500;
                    popupWidth = 700;
                  };
                }
                "org.kde.plasma.globalmenu"
                "org.kde.plasma.panelspacer"
                {
                  iconTasks = {
                    launchers = [
                      "applications:org.kde.dolphin.desktop"
                      "applications:librewolf.desktop"
                      "applications:org.telegram.desktop.desktop"
                      "applications:vesktop-netns.desktop"
                      "applications:kitty.desktop"
                    ];
                    iconsOnly = true;
                    appearance = {
                      showTooltips = false;
                      highlightWindows = false;
                      indicateAudioStreams = true;
                      fill = false;
                      rows = {
                        multirowView = "never";
                        maximum = 1;
                      };
                      iconSpacing = "medium";
                    };
                    behavior = {
                      grouping = {
                        method = "byProgramName";
                        clickAction = "showTextualList";
                      };
                      sortingMethod = "alphabetically";
                      minimizeActiveTaskOnClick = true;
                      middleClickAction = "newInstance";
                      wheel = {
                        switchBetweenTasks = true;
                        ignoreMinimizedTasks = false;
                      };
                      showTasks = {
                        onlyInCurrentScreen = false;
                        onlyInCurrentDesktop = false;
                        onlyInCurrentActivity = false;
                        onlyMinimized = false;
                      };
                      unhideOnAttentionNeeded = false;
                      newTasksAppearOn = "right";
                    };
                  };
                }
                "org.kde.plasma.panelspacer"
                {
                  plasmusicToolbar = {
                    panelIcon = {
                      albumCover = {
                        useAsIcon = false;
                        radius = 8;
                      };
                      icon = "view-media-track";
                    };
                    playbackSource = "auto";
                    musicControls.showPlaybackControls = true;
                    songText = {
                      displayInSeparateLines = true;
                      maximumWidth = 400;
                      scrolling = {
                        behavior = "alwaysScroll";
                        speed = 3;
                      };
                    };
                  };
                }
                {
                  systemTray = {
                    icons = {
                      spacing = "medium";
                      scaleToFit = false;
                    };
                    items = {
                      showAll = false;
                      hidden = [
                        "org.kde.plasma.brightness"
                        "org.kde.plasma.integration"
                        "org.kde.plasma.addons.katesessions"
                        "org.kde.plasma.mediaframe"
                        "org.kde.plasma.battery"
                        #"telegram"
                        #"steam"
                      ];
                      shown = [
                        "org.kde.plasma.notifications"
                        "org.kde.plasma.clipboard"
                        "org.kde.plasma.volume"
                        "org.kde.plasma.netowrkmanagement"
                      ];
                    };
                  };
                }
                "org.kde.plasma.marginseparator"
                {
                  digitalClock = {
                    date = {
                      enable = true;
                      format = "isoDate";
                      position = "belowTime";
                    };
                    time = {
                      showSeconds = "always";
                      format = "24h";
                    };
                    timeZone = {
                      selected = [
                        "Local"
                      ];
                      lastSelected = "Local";
                      changeOnScroll = false;
                    };
                    calendar = {
                      firstDayOfWeek = "monday";
                      plugins = null; # maybe fetch from ya?
                      showWeekNumbers = true;
                    };
                    font = null;
                  };
                }
              ];
              screen = 0;
            }
          ];

          session = {
            general.askForConfirmationOnLogout = true;
            sessionRestore = {
              restoreOpenApplicationsOnLogin = "startWithEmptySession";
              excludeApplications = [ ];
            };
          };

          powerdevil.AC = {
            autoSuspend.action = "nothing";
            autoSuspend.idleTimeout = null;

            dimDisplay.enable = true;
            dimDisplay.idleTimeout = 600;

            powerProfile = "performance";
          };
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
              "Lock Session" = [
                "Screensaver"
                "Meta+Ctrl+Alt+L"
              ];
            };

            "KDE Keyboard Layout Switcher" = {
              "Switch to Last-Used Keyboard Layout" = "";
              "Switch to Next Keyboard Layout" = "Shift+Alt";
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
              "view_zoom_in" = "";
              "view_zoom_out" = "";
            };

            "plasmashell" = {
              # Some setting are set by root configuration so we need to override that
              "next activity" = "none";
              "previous activity" = "none";
            };
          };

          krunner = {
            activateWhenTypingOnDesktop = false;
            historyBehavior = "enableAutoComplete";
            position = "center";
          };

          configFile = {
            "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
            "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
            "kwinrc" = {
              "ElectricBorders" = {
                "TopLeft" = "None";
                "Top" = "None";
              };
              "Plugins" = {
                "zoomEnabled" = false;
              };
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
