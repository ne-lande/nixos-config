let
  c    = import ./colors.nix;
  rgba = hex: "${builtins.substring 1 6 hex}ff";
  rgbaSemi = hex: "${builtins.substring 1 6 hex}40";
in {
  enable = true;
  settings = {
    colors = {
      background      = rgba c.bg;
      text            = rgba c.fg;
      match           = rgba c.accent;
      selection       = rgbaSemi c.accent;
      selection-text  = rgba c.bg;
      selection-match = rgba c.accent;
      border          = rgba c.accent;
    };
    border = {
      width  = 2;
      radius = 8;
    };
  };
}
