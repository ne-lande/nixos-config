{ pkgs, ... }:
{
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-kill-shit.lua" ''
        table.insert(alsa_monitor.rules, {
          matches = {
            {
              { "device.name", "equals", "alsa_card.usb-Razer_Inc_Razer_Kiyo_X_01.00.00-02" },
            },
            {
              { "device.name", "equals", "alsa_card.pci-0000_0b_00.3" },
            },
            {
              { "device.name", "equals", "alsa_card.pci-0000_09_00.1" },
            },
          },
          apply_properties = {
            ["device.disabled"] = true,
            ["device.hidden"] = true,
          },
        })
      '')
    ];
  };
}
