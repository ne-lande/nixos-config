{ ... }: {
  imports = [
    ./hardware.nix
    ./boot.nix
    ./network.nix
    ./nvidia.nix
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

  audio.enable = true;

  powerManagement.cpuFreqGovernor = "powersave";

  zramSwap.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.nelande.extraGroups = [ "video" ];

  system.stateVersion = "23.11"; # Don't change this
}
