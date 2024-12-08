{ pkgs, ... }: {
    programs.gnupg = {

        agent = {
            pinentryPackage = pkgs.pinentry-tty;
            enable = true;
        };
    };
}
