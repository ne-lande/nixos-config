{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  username = config.central.username;
in
{
  options.apps.steam = {
    enable = mkEnableOption "enable steam";
  };

  config = mkIf config.apps.steam.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "on";
          renice = 10;
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          nv_powermizer_mode = 1; # prefer max performance
        };
        cpu = {
          park_cores = "no";
          pin_cores = "yes";
        };
      };
    };

    # gamemode's privileged optimisations (GPU clocks, split_lock_mitigate,
    # ioprio) go through pkexec, which only authorizes the gamemode group.
    users.groups.gamemode.members = [ username ];

    # Source 2 games trigger split locks; the kernel's mitigation throttles
    # the offending thread (~10ms stalls) causing periodic in-game stutter.
    boot.kernel.sysctl."kernel.split_lock_mitigate" = 0;

    environment.sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = "1";
    };

    environment.systemPackages = with pkgs; [
      protonup-qt
      mangohud
    ];
  };
}
