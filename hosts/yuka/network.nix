{ config, pkgs, ...}: {
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
      awgConfig = inputs.secrets.awg.config;
      outIp = inputs.secrets.awg.outIp;
      enable = true;
    };
    zapret.enable = true;
  };
}
