{
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
}
