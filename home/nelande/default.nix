{ pkgs, config, ... }: {
  imports = [
    ./home.nix
  ];

  git.enable = true;
  neovim.enable = true;

  shell = {
    zsh.enable = true;
    starship.enable = true;
  };

  apps = {
    zeditor.enable = true;
    kitty = {
      enable = true;
      background_image = config.static.kitties;
    };
    librewolf.enable = true;
    spicetify.enable = true;
    steam.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      extraGroups = [ "wheel" "networkmanager" "docker" "audio" ];
    };
  };
}
