{ pkgs, ... }: {
    xdg.mime.defaultApplications = {
            # "application/xhtml+xml" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            # "text/html" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            # "text/xml" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            # "x-scheme-handler/ftp" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            # "x-scheme-handler/http" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            # "x-scheme-handler/https" = "${lib.getExe pkgs.librewolf}/share/applications/firefox.desktop";
            "application/xhtml+xml" = "librewolf.desktop";
            "text/html" = "librewolf.desktop";
            "text/xml" = "librewolf.desktop";
            "x-scheme-handler/ftp" = "librewolf.desktop";
            "x-scheme-handler/http" = "librewolf.desktop";
            "x-scheme-handler/https" = "librewolf.desktop";
    };
}
