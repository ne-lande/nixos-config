{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  username = config.central.username;
in
{
  options.omp = {
    enable = mkEnableOption "enable omp (oh-my-pi coding agent)";

    settings = mkOption {
      type = types.nullOr (types.attrsOf types.anything);
      default = null;
      example = {
        startup.quiet = true;
      };
      description = ''
        Settings written to ~/.omp/agent/config.yml on each switch.
        omp rewrites the file itself at runtime (/settings, onboarding);
        those changes are overwritten by the declared values on the next switch.
        Leave null to let omp manage its config entirely.
      '';
    };
  };

  config = mkIf config.omp.enable {
    # The package builds from source against its own pinned nixpkgs
    # (bun2nix + rust toolchain); without the cache that's a very long build.
    nix.settings = {
      substituters = mkDefault [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    home-manager.users.${username} =
      { ... }:
      {
        imports = [ inputs.omp.homeManagerModules.default ];

        programs.omp = {
          enable = true;
          settings = config.omp.settings;
        };
      };
  };
}
