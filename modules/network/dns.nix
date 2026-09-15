{ config, lib, ... }:
with lib;
{
  options.network.dns = {
    enable = mkEnableOption "encrypted DNS via dnscrypt-proxy2";

    serverNames = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Pin specific resolvers (e.g. [ \"cloudflare\" \"quad9-dnscrypt-ip4-nofilter-pri\" ]). Empty = auto-select fastest.";
    };
  };

  config = mkIf config.network.dns.enable {
    # ip netns exec bind-mounts /etc/netns/<name>/resolv.conf over
    # /etc/resolv.conf; without it the namespaces inherit the host's
    # "nameserver 127.0.0.1", which points at their own empty loopback.
    # zapret2 egresses via the ISP, so resolve through host dnscrypt over
    # the veth to avoid plaintext-DNS poisoning of exactly the domains
    # zapret exists to reach.
    environment.etc."netns/zapret2/resolv.conf" = mkIf config.network.zapret2.enable {
      text = "nameserver 172.31.255.5\n";
    };
    networking.firewall.interfaces."zapret2-veth0" = mkIf config.network.zapret2.enable {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };

    networking = {
      nameservers = mkForce [
        "127.0.0.1"
        "::1"
      ];
      networkmanager.dns = "none";
    };

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        # 0.0.0.0 so the zapret2 netns can reach us over its veth, whose
        # address doesn't exist yet when this service binds at boot
        listen_addresses = [
          "0.0.0.0:53"
          "[::1]:53"
        ];

        ipv4_servers = true;
        ipv6_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        http3 = true;

        require_dnssec = true;
        require_nolog = true;
        require_nofilter = true;

        cache = true;
        cache_size = 4096;

        # Hardcoded fallback so bootstrap works before the resolver list is cached
        bootstrap_resolvers = [
          "1.1.1.1:53"
          "9.9.9.9:53"
        ];
        ignore_system_dns = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      }
      // optionalAttrs (config.network.dns.serverNames != [ ]) {
        server_names = config.network.dns.serverNames;
      };
    };
  };
}
