{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Loopback only: enp6s0 is a firewall trustedInterface, so 0.0.0.0 would
  # expose daemon metrics to the whole LAN.
  metrics-default-addr = "127.0.0.1:4200";
in
with lib;
{
  options.docker = {
    enable = mkEnableOption "enable docker";
  };

  config = mkIf config.docker.enable {
    hardware.nvidia-container-toolkit.enable = true;
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          userland-proxy = false;
          experimental = true;
          features.cdi = true;
          metrics-addr = metrics-default-addr;
        };
      };
    };

    # Deliberately no `docker` group membership: the rootful socket is
    # root-equivalent. The CLI talks to the rootless daemon via DOCKER_HOST
    # (set by setSocketVariable).
    environment.systemPackages = with pkgs; [
      dive
      dtop
      dry
    ];
  };
}
