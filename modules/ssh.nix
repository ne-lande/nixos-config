{
  config,
  lib,
  ...
}:
with lib;
{
  options.ssh = {
    enable = mkEnableOption "enable ssh";
  };

  config = mkIf config.ssh.enable {
    # The primary user must be able to authenticate — AllowGroups without
    # any member would lock everyone (including wheel) out of sshd.
    users.users.${config.central.username}.extraGroups = [ "ssh-user" ];

    services.openssh = {
      enable = true;
      ports = [ 22222 ]; # stoopid but what can i tell
      settings = {
        AllowGroups = [ "ssh-user" ];
        UseDns = false; # reverse-DNS lookup only stalls logins
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
