{ config, inputs, ... }:
{
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager = {
      enable = true;
    };

    firewall.trustedInterfaces = [
      "enp6s0"
    ];
  };

  network = {
    dns.enable = true;
    awg = {
      # Rendered by sops-nix from the encrypted store, not inline text.
      awgConfigFile = "/run/secrets/awg-config";
      outIp = inputs.secrets.awg.outIp;
      enable = true;
    };
    # Rendered by sops-nix from the encrypted store, not inline text.
    singbox.subscriptionUrlsFile = "/run/secrets/singbox-urls";
    singbox.enable = true;
    zapret2.enable = true;
  };
}
