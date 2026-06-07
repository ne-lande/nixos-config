let
  c = import ./colors.nix;
in {
  enable = true;
  settings = {
    "background-color" = c.bg;
    "text-color"       = c.fg;
    "border-color"     = c.accent;
    "border-size"      = 2;
    "border-radius"    = 8;
    "default-timeout"  = 2000;
    "ignore-timeout"   = true;
  };
  extraConfig = "";
}
