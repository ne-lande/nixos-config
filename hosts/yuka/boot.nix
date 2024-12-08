{
  boot = {
    # Bootloader.
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    initrd.luks.devices."luks-12a7a548-54bd-47c1-87ce-97d5da75c0d3".device = "/dev/disk/by-uuid/12a7a548-54bd-47c1-87ce-97d5da75c0d3";

    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };
}
