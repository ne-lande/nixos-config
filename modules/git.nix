{ config, lib, ... }:
with lib;
{
  options.git = {
    enable = mkEnableOption "enable git";
  };

  config = mkIf config.git.enable {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "ne-lande";
          email = "nelande.prod@gmail.com";
        };
        init = {
          defaultBranch = "main";
        };
        push = {
          autoSetupRemote = true;
        };
        advice.addIgnoredFile = false;
        core.hooksPath = ".githooks";
      };
    };
  };
}
