{ pkgs, ... }: {
  programs.plasma = {
    enable = true;

    #
    # Some high-level settings:
    #
    workspace = {
      clickItemTo = "select";
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor.theme = "Breeze-Light";
      iconTheme = "breeze-dark";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
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


    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
      };

      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout"="";
        "Switch to Next Keyboard Layout"="";
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
    };


    #
    # Some low-level settings:
    #
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
}
