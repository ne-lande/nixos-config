{
  virtualisation = {
    docker = {
        enable = true;
        daemon.settings = {
            userland-proxy = false;
            experimental = true;
            metrics-addr = "0.0.0.0:4200";
        };
    };

    # litteraly portainer lmao!
    #arion = {
    #  backend = "docker";
    #  projects = {
    #    "db".settings.services."db".service = {
    #      image = "";
    #      restart = "unless-stopped";
    #      environment = { POSTGRESS_PASSWORD = "password"; };
    #    };
    #  };
    };
  };
}
