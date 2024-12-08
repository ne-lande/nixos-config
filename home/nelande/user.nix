{ pkgs, ... }: {
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.nelande = {
      isNormalUser = true;
      description = "nelande";
      extraGroups = [ "wheel" "networkmanager" "docker" "no-internet" ];
    };

    users.tcpcryptd = {
        group = "tcpcryptd";
    };
    groups = {
        tcpcryptd = {};
    };
  };
}
