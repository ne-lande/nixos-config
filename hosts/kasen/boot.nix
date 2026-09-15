{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # Keep the boot menu short and /boot from filling up; nh clean
        # handles the store side but not ESP entries until GC.
        configurationLimit = 10;
      };
    };

    initrd = {
      verbose = false;
      systemd.enable = true;

      # TPM2 auto-unlock: systemd-cryptsetup uses the TPM2 token when
      # enrolled (systemd-cryptenroll), otherwise falls back to the
      # passphrase prompt. Existing passphrase slot stays untouched.
      luks.devices."crypted".crypttabExtraOpts = [ "tpm2-device=auto" ];
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

  fileSystems."/stor" = {
    device = "/dev/disk/by-uuid/59645dd4-8f7f-46f6-b79b-835aef96577c";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "exec"
    ];
  };
}
