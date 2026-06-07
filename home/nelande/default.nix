{
  pkgs,
  config,
  inputs,
  ...
}:
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

  docker.enable = true;
  kube.enable = true;
  lists.enable = true;
  git = {
    enable = true;
    userName = inputs.secrets.git.userName;
    userEmail = inputs.secrets.git.userEmail;
  };
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
    kitty.enable = true;
    librewolf.enable = true;
    lwchrome.enable = true;
    steam.enable = true;
    zed-editor.enable = true;
    vesktop.enable = true;
    obsidian.enable = true;
    obs-studio.enable = true;
  };

  xdg.mime.defaultApplications = {
    "x-scheme-handler/zoommtg" = "Zoom.desktop";
  };

  users = {
    defaultUserShell = pkgs.fish;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      hashedPassword = inputs.secrets.users.nelande.hashedPassword;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
      ];
    };
  };
}
