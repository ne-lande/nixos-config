{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.central.username;
in
with lib;
{
  options.DE.awww = {
    enable = mkEnableOption "enable awww";
    backgroundDir = mkOption {
      type = types.str;
      description = "Directory to pick random wallpapers from.";
    };
  };

  config = mkIf config.DE.awww.enable {
    home-manager.users.${username} = {...}: {
      services.awww.enable = true;
    };

    systemd.user.timers."awww-timer" = {
      wantedBy = [ "timers.target" ];
      after = ["awww.service"];
      requires = ["awww.service"];
      timerConfig = {
        User = username;
        Unit = "awww-random.service";
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
        Persistent = true;
      };
    };

    systemd.user.services."awww-random" = {
      after = ["awww.service"];
      requires = ["awww.service"];
      serviceConfig = {
        Type = "oneshot";
        User = username;
        ExecStart = with pkgs;
          writers.writeBash "awww-random" ''
            set -e

            BG_DIR="${config.DE.awww.backgroundDir}"
            if [[ ! -d "$BG_DIR" ]]; then
              echo "Error: Directory $BG_DIR does not exist." >&2
              exit 1
            fi

            RANDOM_BG=$(${findutils}/bin/find $BG_DIR -maxdepth 1 -type f -print0 | ${coreutils-full}/bin/shuf -z -n 1 | tr -d '\0')

            if [[ -z "$RANDOM_BG" ]]; then
              echo "Error: No background images found in $BG_DIR." >&2
              exit 1
            fi

            echo "setting $RANDOM_BG as background image" >&2

            /etc/profiles/per-user/${username}/bin/awww img $RANDOM_BG
          '';
      };
    };
  };
}
