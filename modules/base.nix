{ ... }:
{
  # Shared host base — always on, no toggle: locale, timezone, nixpkgs
  # policy. Previously copy-pasted into every host and hidden inside
  # lists.enable (which made unfree packages depend on a package-list
  # toggle).

  # Weekly TRIM for SSDs/NVMe (incl. btrfs); harmless elsewhere.
  services.fstrim.enable = true;

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "C.UTF-8";
      LC_COLLATE = "C.UTF-8";
      LC_NUMERIC = "C.UTF-8";
    };
  };

  time.timeZone = "Europe/Moscow";

  nixpkgs.config = {
    allowUnfree = true;
    allowInsecure = false;
    # Inherited from the original lists.nix block; verify nothing needs it
    # and drop.
    allowUnsupportedSystem = true;
    # Stale entries are harmless (matched by version) — prune once nixpkgs
    # ships a pnpm past 10.29.2.
    permittedInsecurePackages = [ "pnpm-10.29.2" ];
  };
}
