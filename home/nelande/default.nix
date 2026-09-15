{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  username = "nelande";
  # kasen renders secrets via sops-nix at runtime; other hosts read
  # host-local plain files under /etc/secrets/nelande (kept outside
  # the flake source so they never land in the world-readable store).
  useSopsSecrets = config.networking.hostName == "kasen";
  secret = name: if useSopsSecrets then "/run/secrets/${name}" else "/etc/secrets/nelande/${name}";
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
    userEmail = inputs.secrets.git.userEmail;
  };
  neovim.enable = true;
  # TODO: re-enable when upstream omp builds again — 18.1.22 source build is
  # broken (bun dep resolution) and no binary is published on the cache.
  omp.enable = false;
  music = {
    enable = true;
    address = "127.0.0.1";
    port = 6600;
  };
  video.enable = true;

  shell = {
    fish.enable = true;
  };

  email = {
    enable = true;
    accounts = {
      gmail = {
        address = inputs.secrets.email.gmail.address;
        appPasswordFile = secret "email-gmail-appPassword";
      };
      yandex = {
        address = inputs.secrets.email.yandex.address;
        appPasswordFile = secret "email-yandex-appPassword";
      };
      mailru = {
        address = inputs.secrets.email.mailru.address;
        appPasswordFile = secret "email-mailru-appPassword";
      };
    };
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
    minecraft.enable = true;
    zoom.enable = true;
  };

  users = {
    defaultUserShell = pkgs.fish;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      hashedPasswordFile =
        if useSopsSecrets then
          "/run/secrets-for-users/nelande-hashedPassword"
        else
          "/etc/secrets/nelande/hashed-password";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
      ];
    };
  };
}
