{ config, ... }:
{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.finegrained = false;
    # Required for suspend/resume: saves VRAM allocations across sleep
    # (NVreg_PreserveVideoMemoryAllocations + nvidia-suspend/resume units).
    # swayidle auto-suspends after 10 min, so without this resume comes back
    # to a black screen or corrupted textures.
    powerManagement.enable = true;
    open = true;
    #nvidiaSettings = true;
    # 610.xx has known freezes/stutter in Deadlock; users confirm 595.84 and
    # 580.119 work. Revert to .latest once 610 is fixed upstream.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
