{ pkgs, ...}: {
  boot = {
    # Bootloader.
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    initrd.luks.devices."luks-9ae22b1f-5984-45a2-8375-ff4c490077e9".device = "/dev/disk/by-uuid/9ae22b1f-5984-45a2-8375-ff4c490077e9";

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  fileSystems."/stor" = {
   device = "/dev/disk/by-uuid/59645dd4-8f7f-46f6-b79b-835aef96577c";
   fsType = "btrfs";
   options = [
     "users"
     "nofail"
   ];
  };
}
