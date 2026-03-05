{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.finegrained = false;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    # unless kernel module is supported on 6.19
    # https://github.com/NixOS/nixpkgs/issues/489947
    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1021
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    package =
      let
        base = config.boot.kernelPackages.nvidiaPackages.latest;
        cachyos-nvidia-patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
          sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
        };
      in
      base
      // {
        open = base.open.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
        });
      };
  };
}
