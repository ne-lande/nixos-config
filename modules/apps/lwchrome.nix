# light weight chromium
# with pkg set as ungoogled chromium
# with preset proxy filter for burp/caido etc
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
  options.apps.lwchrome = {
    enable = mkEnableOption "enable lightweight chromium (ungoogled)";
  };

  config = mkIf config.apps.lwchrome.enable {
    home-manager.users.${username} =
      { ... }:
      {
        programs.chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;

          commandLineArgs = [
            "--no-first-run"
            "--disable-sync"
            "--disable-background-networking"
            "--disable-component-extensions-with-background-pages"
            "--disable-default-apps"
            "--no-default-browser-check"
          ];
        };
      };
  };
}
