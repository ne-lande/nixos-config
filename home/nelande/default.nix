{ pkgs, config, ... }:
let
  username = "nelande";
in
{
  central = {
    username = username;
  };

  home-manager.users.${username} =
    { ... }:
    {
      home = {
        username = username;
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };

  programs.nh.enable = true;
  docker.enable = true;
  kube.enable = true;
  lists.enable = true;
  git.enable = true;
  neovim.enable = true;
  music = {
    enable = true;
    address = "127.0.0.1";
    port = 6600;
  };
  video.enable = true;

  shell = {
    fish.enable = true;
  };

  apps = {
    kitty = {
      enable = true;
      background_image = config.static.kitties;
    };
    librewolf.enable = true;
    steam.enable = true;
    zed-editor.enable = true;
    vesktop.enable = true;
    obsidian.enable = true;
  };

  users = {
    defaultUserShell = pkgs.fish;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
      ];
    };
  };
}
