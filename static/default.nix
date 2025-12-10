{ lib, ... }:
with lib;
{
  # i cant find another way :(
  options.static = {
    gtfo = mkOption {
      type = lib.types.str;
      default = "${./gtfo-2k-16t9.webp}";
    };

    isaac = mkOption {
      type = lib.types.str;
      default = "${./isaac-1t1.jpg}";
    };

    kitties = mkOption {
      type = lib.types.str;
      default = "${./kitties-181t256.jpg}";
    };

    yuka = mkOption {
      type = lib.types.str;
      default = "${./yuka-160t103.jpg}";
    };
  };
}
