{
  lib,
  ...
}:
with lib;
{
  # Dont set defaults, user must explicilty set them in home configurations!
  options.central = {
    hostname = mkOption {
      type = types.str;
      example = "lab.home";
      description = "Host FQDN";
    };

    username = mkOption {
      type = types.str;
      example = "john";
      description = "Well... username?";
    };

    plasma-wallpaper = mkOption {
      type = types.str;
      example = "";
      description = "";
    };
  };
}
