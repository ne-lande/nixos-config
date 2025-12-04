{ pkgs, ... }:
{
  imports = [
    ./home.nix
  ];

  git.enable = true;
  neovim.enable = true;

  shell = {
    fish.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    groups.libvirtd.members = [ "honeset" ];
    users.honeset = {
      isNormalUser = true;
      description = "honeset";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "no-internet"
      ];
    };
  };
}
