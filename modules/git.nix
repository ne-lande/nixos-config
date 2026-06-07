{ config, lib, ... }:
with lib;
{
  options.git = {
    enable = mkEnableOption "enable git";
    userName = mkOption {
      type = types.str;
      default = "ne-lande";
    };
    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git commit email. Leave null and configure locally or via secrets.";
    };
  };

  config = mkIf config.git.enable {
    programs.git = {
      enable = true;
      config = {
        user = { name = config.git.userName; }
          // optionalAttrs (config.git.userEmail != null) { email = config.git.userEmail; };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        advice.addIgnoredFile = false;
        core.hooksPath = ".githooks";
      };
    };
  };
}
