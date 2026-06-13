{ ... }: {
  imports = [
    ./hardware.nix
    ./boot.nix
    ./network.nix
    ./nvidia.nix
    ./sound.nix
  ];

  central = {
    hostname = "yuka";
  };

  hardware.enableAllFirmware = true;

  DE.niri = {
    enable = true;
    configFile = ./niri-config.kdl;
  };
  DE.awww = {
    enable = true;
    backgroundDir = "/home/nelande/Backgrounds";
  };

  nix-configuration.enable = true;

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

  powerManagement.cpuFreqGovernor = "powersave";

  zramSwap.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.printing.enable = false;
  security.rtkit.enable = true;

  users.users.nelande.extraGroups = [ "video" ];

  system.stateVersion = "23.11"; # Don't change this
}
