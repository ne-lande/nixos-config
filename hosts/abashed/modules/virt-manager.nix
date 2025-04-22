{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "honeset" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
