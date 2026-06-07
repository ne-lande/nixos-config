{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      #grub = {
      #  enable = true;
      #  device = "nodev";
      #  efiSupport = true;
      #  useOSProber = false;

      #  gfxmodeEfi = "5120x1440";
      #  gfxmodeBios = "5120x1440";
      #  gfxpayloadEfi = "keep";
      #  gfxpayloadBios = "keep";
      #};
    };

    initrd = {
      verbose = false;
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "kvm-amd"
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
        "nvidia_uvm"
      ];
    };

    plymouth = {
      enable = true;
      theme = "rings";
      font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    consoleLogLevel = 3;

    kernelParams = [
      "console=tty1"
      "quiet"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "systemd.show_status=auto"
      "nvidia-drm.fbdev=1"
    ];
  };

  #boot.initrd.luks.devices."luks-bc46ce17-eb27-4ad3-a7fe-b7dfd665e60c".device =
  #  "/dev/disk/by-uuid/bc46ce17-eb27-4ad3-a7fe-b7dfd665e60c";
  #boot.initrd.luks.devices."luks-95aaa045-995b-44a5-8278-d7cad3559599".device =
  #  "/dev/disk/by-uuid/95aaa045-995b-44a5-8278-d7cad3559599";

  #fileSystems."/old-root" = {
  #  device = "/dev/disk/by-uuid/7a8d0dbb-e04d-4e89-9a6a-22db04ca1ea6";
  #  fsType = "ext4";
  #};

  # old boot
  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-uuid/9729-4535";
  #  fsType = "vfat";
  #  options = [
  #    "fmask=0022"
  #    "dmask=0022"
  #  ];
  #};

  # new boot
  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-uuid/b7c8-fde7";
  #  fsType = "vfat";
  #  options = [
  #    "fmask=0022"
  #    "dmask=0022"
  #  ];
  #};

  fileSystems."/stor" = {
    device = "/dev/disk/by-uuid/59645dd4-8f7f-46f6-b79b-835aef96577c";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "exec"
    ];
  };

  #swapDevices = [
  #  { device = "/dev/disk/by-uuid/90787e9d-bd79-4c96-bad0-cdf3d445aed1"; }
  #];
}
