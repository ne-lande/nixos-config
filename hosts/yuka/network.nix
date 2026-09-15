{
  config,
  pkgs,
  inputs,
  ...
}:
{
  networking = {
    enableIPv6 = true;
    hostName = config.central.hostname;
    networkmanager.enable = true;

    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" ];
    };
  };

  network = {
    #zerotier.enable = true;
    awg = {
      # Host-local plain file (never inside the /nix-secrets flake source,
      # which gets copied to the store). Root-owned 0400.
      awgConfigFile = "/etc/secrets/awg.conf";
      outIp = inputs.secrets.awg.outIp;
      enable = true;
    };
    zapret2.enable = true;
  };
}
