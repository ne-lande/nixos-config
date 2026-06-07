{ config, lib, pkgs, ... }:
with lib;
{
  options.apps.minecraft = {
    enable = mkEnableOption "enable minecraft / prismlauncher";
  };

  config = mkIf config.apps.minecraft.enable {
    environment.systemPackages = with pkgs; [
      prismlauncher

      # Multiple Java versions — PrismLauncher auto-detects these
      temurin-bin-8   # Minecraft < 1.17
      temurin-bin-17  # Minecraft 1.17–1.20
      temurin-bin-21  # Minecraft 1.21+
    ];

    # Expose Java binaries so PrismLauncher can find them via PATH detection
    programs.java = {
      enable = true;
      package = pkgs.temurin-bin-21;
    };

    # Open LAN multiplayer port
    networking.firewall.allowedUDPPorts = [ 19132 ];
    networking.firewall.allowedTCPPortRanges = [
      { from = 25500; to = 25600; } # LAN world range
    ];
  };
}
