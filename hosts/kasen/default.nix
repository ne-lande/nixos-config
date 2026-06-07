{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./nvidia.nix
    ./sound.nix
    ./network.nix
  ];

  central = {
    hostname = "kasen";
    #plasma-wallpaper = config.static.gtfo;
  };

  #DE.plasma.enable = true;
  DE.niri = {
    enable = true;
    configFile = ./niri-config.kdl;
  };
  DE.awww = {
    enable = true;
    backgroundDir = "/stor/Backgrounds";
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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  time.timeZone = "Europe/Moscow";

  powerManagement.cpuFreqGovernor = "performance";

  services.printing.enable = false;
  security.rtkit.enable = true;

  system.stateVersion = "23.11"; # Don't change this
}
