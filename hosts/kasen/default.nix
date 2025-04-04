{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./modules
    ./packages.nix
  ];

  # i wont step on these ever again
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
    };
  };


  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_MESSAGES = "C.UTF-8";
    LC_COLLATE = "C.UTF-8";
    LC_NUMERIC = "C.UTF-8";
  };

  powerManagement.cpuFreqGovernor = "performance";

  services.printing.enable = false;
  security.rtkit.enable = true;

  system.stateVersion = "23.11"; # Don't change this
}
