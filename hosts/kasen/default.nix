{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./nvidia.nix
    ./network.nix
    ./secrets.nix
  ];

  central = {
    hostname = "kasen";
  };

  DE.niri = {
    enable = true;
    configFile = ./niri-config.kdl;
  };
  DE.awww = {
    enable = true;
    backgroundDir = "/stor/Backgrounds";
  };

  nix-configuration.enable = true;

  audio.enable = true;

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

  powerManagement.cpuFreqGovernor = "performance";

  # No disk swap is configured; without any swap, memory pressure turns into
  # direct-reclaim stalls (periodic frame hitches in games) or OOM kills.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Upstream zram-generator tuning: default swappiness (60) makes the kernel
  # prefer dropping page cache over compressing to zram, so reclaim stalls
  # persist even with zram enabled.
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };

  # sched_ext scheduler (xanmod ships CONFIG_SCHED_CLASS_EXT); LAVD is
  # latency-oriented and improves frame pacing under background load.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  system.stateVersion = "23.11"; # Don't change this
}
