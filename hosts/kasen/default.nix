{ config, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./boot.nix
    ./nvidia.nix
    ./sound.nix
    ./network.nix
    ./packages.nix
  ];

  central = {
    hostname = "kasen";
    plasma-wallpaper = config.static.gtfo;
  };

  DE.plasma.enable = true;

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

  # Regional
  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "C.UTF-8";
      LC_COLLATE = "C.UTF-8";
      LC_NUMERIC = "C.UTF-8";
    };
  };

  time.timeZone = "Europe/Moscow";

  powerManagement.cpuFreqGovernor = "performance";

  services.printing.enable = false;
  security.rtkit.enable = true;

  system.stateVersion = "23.11"; # Don't change this
}
