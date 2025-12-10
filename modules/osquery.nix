{ config, lib, ... }:
with lib;
{
  options.osquery = {
    enable = mkEnableOption "enable osquery";
  };

  config = mkIf config.osquery.enable {
    services.osquery = {
      enable = true;
    };
  };
}
