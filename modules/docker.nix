{ config, lib, pkgs, types, ... }:
let
  metrics-default-addr = "0.0.0.0:4200";
in with lib;
{
  options.docker = {
    enable = mkEnableOption "enable docker";
  };

  config = mkIf config.docker.enable {
    virtualisation = {
      docker = {
        enable = true;
        daemon.settings = {
          userland-proxy = false;
          experimental = true;
          metrics-addr = metrics-default-addr;
        };
      };
    };
  };
}
