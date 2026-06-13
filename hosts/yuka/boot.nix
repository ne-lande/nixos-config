{ config, pkgs, ...} : {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };
}
