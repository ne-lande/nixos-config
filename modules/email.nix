{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  username = config.central.username;
  cfg = config.email;

  # Secrets are runtime files (sops-nix on kasen, host-local under
  # /etc/secrets elsewhere) — read by passwordCommand, never copied
  # into the world-readable store.

  # Provider connection defaults; per-account options override.
  providers = {
    gmail = {
      imapHost = "imap.gmail.com";
      smtpHost = "smtp.gmail.com";
      smtpPort = 587;
      smtpStartTls = true;
      primary = true;
      patterns = [
        "*"
        "[Gmail]/*"
      ];
    };
    yandex = {
      imapHost = "imap.yandex.ru";
      smtpHost = "smtp.yandex.ru";
      smtpPort = 465;
    };
    mailru = {
      imapHost = "imap.mail.ru";
      smtpHost = "smtp.mail.ru";
      smtpPort = 465;
    };
  };

  mkAccount =
    name:
    {
      address,
      appPasswordFile,
      imapHost,
      smtpHost,
      smtpPort,
      smtpStartTls ? false,
      primary ? false,
      patterns ? [ "*" ],
    }:
    {
      inherit primary address;
      userName = address;
      passwordCommand = "cat ${appPasswordFile}";
      realName = username;

      imap = {
        host = imapHost;
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = smtpHost;
        port = smtpPort;
        tls = {
          enable = true;
          useStartTls = smtpStartTls;
        };
      };

      mbsync = {
        enable = true;
        create = "maildir";
        expunge = "both";
        inherit patterns;
      };

      aerc.enable = true;
      msmtp.enable = true;
    };

  merged = mapAttrs (name: acct: providers.${name} or { } // acct) cfg.accounts;
in
{
  options.email = {
    enable = mkEnableOption "email stack (aerc + mbsync + msmtp)";

    syncInterval = mkOption {
      type = types.str;
      default = "*:0/5";
      description = "Systemd calendar expression for mbsync sync frequency.";
    };

    accounts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            address = mkOption { type = types.str; };
            appPasswordFile = mkOption {
              type = types.str;
              description = "Runtime file with the app password, readable by the user (sops-nix secret or host-local file under /etc/secrets).";
            };
          };
        }
      );
      default = { };
      description = "Accounts to sync. Connection details (hosts/ports/patterns) come from the known providers (gmail, yandex, mailru); unknown account names must set them via the provider defaults being empty.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = merged == { } || count (a: a.primary or false) (attrValues merged) == 1;
        message = "email.accounts: exactly one account must be primary";
      }
    ];

    home-manager.users.${username} =
      { ... }:
      {
        home.packages = with pkgs; [
          w3m
        ];

        accounts.email = {
          maildirBasePath = "Mail";

          accounts = mapAttrs (name: acct: mkAccount name acct) merged;
        };

        programs.mbsync.enable = true;
        programs.msmtp.enable = true;

        programs.aerc = {
          enable = true;
          extraConfig = {
            general = {
              default-save-path = "~/Downloads";
              unsafe-accounts-conf = true;
            };
            viewer = {
              pager = "less -R";
              alternatives = "text/plain,text/html";
            };
            filters = {
              "text/plain" = "cat";
              "text/html" = "w3m -T text/html -dump";
              "image/png" = "kitten icat -";
              "image/jpeg" = "kitten icat -";
              "image/gif" = "kitten icat -";
              "image/webp" = "kitten icat -";
            };
            compose = {
              editor = "$EDITOR";
            };
          };
        };

        services.mbsync = {
          enable = true;
          frequency = cfg.syncInterval;
          postExec = "${pkgs.writeShellScript "mbsync-post" ''
            ${pkgs.notmuch}/bin/notmuch new --quiet
            count=$(${pkgs.notmuch}/bin/notmuch count tag:new)
            ${pkgs.notmuch}/bin/notmuch tag +inbox +unread -new -- tag:new
            if [ "$count" -gt 0 ]; then
              ${pkgs.libnotify}/bin/notify-send \
                --icon=mail-unread \
                --app-name=aerc \
                "New mail" "$count new message(s)"
            fi
          ''}";
        };

        programs.notmuch = {
          enable = true;
          new.tags = [ "new" ];
          extraConfig.user =
            let
              primary = findFirst (a: a.primary or false) (head (attrValues merged)) (attrValues merged);
              others = filter (a: !(a.primary or false)) (attrValues merged);
            in
            {
              name = username;
              primary_email = primary.address;
              other_email = concatStringsSep ";" (map (a: a.address) others);
            };
        };
      };
  };
}
