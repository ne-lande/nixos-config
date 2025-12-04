{ config, pkgs, ...} : {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
