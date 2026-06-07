{ config, lib, ... }:
with lib;
{
  options.virt-manager = {
    enable = mkEnableOption "enable virt-manager";
  };

  config = mkIf config.virt-manager.enable {
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
