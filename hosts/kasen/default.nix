{ config, pkgs, ... }:
{
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

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # i wont step on these ever again
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  };
  services.mpd = {
    enable = true;
    user = "nelande";
    group = "audio";
    musicDirectory = "/stor/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';
  };

  virtualisation.docker.enable = true;
  time.timeZone = "Europe/Moscow";

  powerManagement.cpuFreqGovernor = "performance";

  services.printing.enable = false;
  security.rtkit.enable = true;

  system.stateVersion = "23.11"; # Don't change this
}
