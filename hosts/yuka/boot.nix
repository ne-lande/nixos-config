{ config, pkgs, ...} : {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    #plymouth = {
    #  enable = true;
    #  theme = "breeze";
    #};
  };
}
