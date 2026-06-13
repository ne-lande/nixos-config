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
  options.DE.niri = {
    enable = mkEnableOption "enable niri wayland compositor";
    configFile = mkOption {
      type = types.path;
      description = "Path to niri config.kdl";
    };
  };

  config = mkIf config.DE.niri.enable {
    environment.systemPackages = with pkgs; [
      xwayland-satellite # X11 support for Wayland compositors
      # Essential Wayland utilities
      waybar # status bar
      swaylock # screen locker
      lxqt.lxqt-policykit # polkit authentication agent
      nautilus # file manager
      networkmanagerapplet # network tray icon
      blueman # bluetooth manager
      pavucontrol # audio volume control
      xdg-desktop-portal-gnome # additional portal for GNOME integration
      wl-clipboard # clipboard utilities for Wayland
      grim # screenshot utility
      slurp # region selector for screenshots
      xdg-utils # desktop integration (open URLs, etc.)
      brightnessctl # backlight control
    ];

    # Display manager configuration for niri
    # Example with SDDM:
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.niri.package}/bin/niri-session";
          user = username;
        };
      };
    };

    # Configure necessary environment variables for Wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      # SDL_VIDEODRIVER = "wayland" intentionally removed — forcing Wayland on SDL
      # breaks Proton/Wine games which expect XWayland, causing image freeze
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_SESSION_TYPE = "wayland";
      # NVIDIA Wayland backend — required for correct GBM/EGL path on NVIDIA
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      # Let newer Proton opt-in to native Wayland when it can handle it
      PROTON_ENABLE_WAYLAND = "1";
    };

    # Security/XDG portal setup for Wayland
    xdg.portal = {
      enable = true;
      wlr.enable = true; # For wlroots-based compositors
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
    };

    # Hardware acceleration for Wayland
    # Audio and screen sharing
    services.pulseaudio.enable = false;
    security.rtkit.enable = mkDefault true;
    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      alsa.support32Bit = mkDefault true;
      pulse.enable = mkDefault true;
      wireplumber.enable = mkDefault true;
    };

    services.blueman.enable = mkDefault true;

    security.polkit.enable = true; # polkit
    services.gnome.gnome-keyring.enable = true; # secret service
    security.pam.services.swaylock = { };

    programs.niri.enable = true;
    home-manager.users.${username} =
      { ... }:
      {
        programs.waybar = import ./waybar.nix;
        programs.fuzzel = import ./fuzzel.nix;
        programs.swaylock = import ./swaylock.nix;

        services.mako = import ./mako.nix;
        #services.awww = import ./awww.nix;

        xdg.configFile."niri/config.kdl".source = config.DE.niri.configFile;
        services = {
          polkit-gnome.enable = true; # polkit
          swayidle = {
            enable = true;
            events = {
              before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
              lock = "${pkgs.swaylock}/bin/swaylock -f";
            };
            timeouts = [
              {
                timeout = 300;
                command = "${pkgs.swaylock}/bin/swaylock -f";
              }
              {
                timeout = 600;
                command = "systemctl suspend";
              }
            ];
          };
        };
      };
  };
}
