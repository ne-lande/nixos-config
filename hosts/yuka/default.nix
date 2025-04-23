{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./modules
    ./packages.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  virtualisation.docker.enable = true;
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  powerManagement.cpuFreqGovernor = "performance";


  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = false;
  security.rtkit.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "E4DA7455B28258DA"
    ];
  };

  system.stateVersion = "23.11"; # Don't change this
}
