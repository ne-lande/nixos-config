{
  # Enable the X11 windowing system.
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
  services.displayManager.autoLogin.user = "nelande";
  services.displayManager.defaultSession = "plasmax11"; # plasma for wayland
}
