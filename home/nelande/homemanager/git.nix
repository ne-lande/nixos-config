{ pkgs, config, ... }:{
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
}
