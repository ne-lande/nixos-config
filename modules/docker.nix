{
  config,
  lib,
  pkgs,
  ...
}:
let
  metrics-default-addr = "0.0.0.0:4200";
  username = config.central.username;
in
with lib;
{
  options.docker = {
    enable = mkEnableOption "enable docker";
  };

  config = mkIf config.docker.enable {
    users.extraGroups.docker.members = [ username ];

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          userland-proxy = false;
          experimental = true;
          metrics-addr = metrics-default-addr;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      dive
      dtop
      dry
    ];
  };
}
