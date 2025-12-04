{ pkgs, config, ... }:
{
  imports = [
    ./home.nix
  ];

  programs.nh = {
    enable = true;
  };

  git.enable = true;
  neovim.enable = true;

  shell = {
    zsh.enable = true;
  };

  apps = {
    kitty = {
      enable = true;
      background_image = config.static.kitties;
    };
    librewolf.enable = true;
  };

  ## A lot of here is closed-source so configs are kept as a secret too
  secrets.modules.osquery = {
    enable = true;
    blockedDirectories = "/nix/store";
  };
  secrets.modules.skotty.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "audio"
        "tss"
      ];
    };
  };
}
