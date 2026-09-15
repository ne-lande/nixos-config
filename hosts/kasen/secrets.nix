{
  inputs,
  pkgs,
  ...
}:
{
  sops = {
    age = {
      # Identity file at /var/lib/sops-nix/key.txt: recovery age key now,
      # TPM identity (age-plugin-tpm) appended once fTPM is enabled in BIOS.
      # Root-owned, lives on the LUKS-encrypted root.
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
      # Needed by sops-install-secrets once the TPM identity is in the key file.
      plugins = [ pkgs.age-plugin-tpm ];
    };

    secrets = {
      email-gmail-appPassword = {
        sopsFile = inputs.secrets.sopsFiles.email;
        key = "gmail-appPassword";
        owner = "nelande";
      };
      email-yandex-appPassword = {
        sopsFile = inputs.secrets.sopsFiles.email;
        key = "yandex-appPassword";
        owner = "nelande";
      };
      email-mailru-appPassword = {
        sopsFile = inputs.secrets.sopsFiles.email;
        key = "mailru-appPassword";
        owner = "nelande";
      };
      nelande-hashedPassword = {
        sopsFile = inputs.secrets.sopsFiles.user;
        key = "nelande-hashedPassword";
        neededForUsers = true;
      };
      awg-config = {
        sopsFile = inputs.secrets.sopsFiles.awg;
        key = "awg-config";
        restartUnits = [ "awg.service" ];
      };
      singbox-urls = {
        sopsFile = inputs.secrets.sopsFiles.singbox;
        key = "singbox-urls";
        # secret edit re-runs the updater, whose ExecStartPost (re)starts singbox
        restartUnits = [ "singbox-update.service" ];
      };
    };
  };
}
