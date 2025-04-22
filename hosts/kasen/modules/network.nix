{ rootPath, ... }:
let
  secrets = import ../../../sec.nix;
in
{
  networking = {
    enableIPv6 = true;
    hostName = "kasen";
    networkmanager.enable = true;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp6s0";
    };

    # allow any traffic on intranet
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "ztwfupmdli" "enp6s0" ];
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

  };

  services.zerotierone = {
    enable = true;
    joinNetworks = secrets.zerotier.networks;
  };
  #services.dnscrypt-proxy2 = {
  #  enable = true;
  #  settings = {
  #    ipv6_servers = true;
  #    require_dnssec = true;
  #
  #    sources.public-resolvers = {
  #      urls = [
  #        "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
  #        "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
  #      ];
  #      cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
  #      minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
  #    };
  #
  #    # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
  #     server_names = [
  #       "a-and-a"
  #     ];
  #  };
  #};

  #systemd.services.dnscrypt-proxy2.serviceConfig = {
  #  StateDirectory = "dnscrypt-proxy";
  #};
}
