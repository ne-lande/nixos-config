{ config, lib, pkgs, types, ... }:
with lib;
{
  options.ssh = {
    enable = mkEnableOption "enable neovim";
  };

  config = mkIf config.ssh.enable {
    users.groups.ssh-user = {};

    services.openssh = {
      enable = true;
      ports = [ 22222 ]; # stoopid but what can i tell
      settings = {
        AllowGroups = [ "ssh-user" ];
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "no";
        PasswordAuthentication = false;

        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-256"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes256-ctr"
        ];
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];
      };
    };
  };
}
