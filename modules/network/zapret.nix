{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib;
let
  tp = mylib.mkTinyproxyConf {
    name = "zapret";
    port = 8888;
    listenIp = "172.31.255.2";
    allowIps = [
      "127.0.0.1"
      "172.31.255.1"
    ];
  };
  zdy = pkgs.fetchFromGitHub {
    "owner" = "Flowseal";
    "repo" = "zapret-discord-youtube";
    "rev" = "9a1ce92593bd9af4e2e0b4af4d9db69c71e4af00";
    "hash" = "sha256-k81WLuDrvG3zjVf3wVgnUTrpomJbuipGJv3TGX7suqc=";
  };
  bin = "${zdy}/bin";
  netns-exec = mylib.mkNetnsExec pkgs "zapret";
in
{
  options.network.zapret = {
    enable = mkEnableOption "enable zapret";
    tinyProxyConf = mkOption {
      type = types.lines;
      default = tp.conf;
      description = "tinyproxy configuration for the zapret namespace";
    };
  };

  config = mkIf config.network.zapret.enable (
    let
      tinyproxyConfFile = pkgs.writeText "tinyproxy-zapret.conf" config.network.zapret.tinyProxyConf;
    in
    {
      environment.systemPackages = with pkgs; [
        zapret
        netns-exec.run
      ];

      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      security.sudo = {
        extraRules = [
          (netns-exec.sudoRule // { users = [ config.central.username ]; })
        ];
        extraConfig = netns-exec.sudoEnvKeep;
      };

      systemd.services.zapret = mylib.mkNetnsProxyService pkgs {
        name = "zapret";
        hostVethIp = "172.31.255.1";
        nsVethIp = "172.31.255.2";
        subnet = "172.31.255.0";
        qnum = 200;
        # TCP and QUIC/Discord: conntrack early packets only
        nfqRules = [
          {
            proto = "tcp";
          }
          {
            proto = "udp";
          }
        ];
        daemonCmd = ''
          ${pkgs.iproute2}/bin/ip netns exec zapret ${pkgs.zapret}/bin/nfqws \
            --pidfile=/tmp/zapret.pid \
            --user nobody \
            --qnum=200 \
            --filter-udp=443 \
            --dpi-desync=fake \
            --dpi-desync-repeats=11 \
            --dpi-desync-fake-quic="${bin}/quic_initial_www_google_com.bin" \
            --filter-udp=19294-19344,50000-50100 \
            --filter-l7=discord,stun \
            --dpi-desync=fake \
            --dpi-desync-repeats=6 \
            --new \
            --filter-tcp=2053,2083,2087,2096,8443 \
            --hostlist-domains=discord.media \
            --dpi-desync=fake,multisplit \
            --dpi-desync-split-seqovl=681 \
            --dpi-desync-split-pos=1 \
            --dpi-desync-fooling=ts \
            --dpi-desync-repeats=8 \
            --dpi-desync-split-seqovl-pattern="${bin}/tls_clienthello_www_google_com.bin" \
            --dpi-desync-fake-tls="${bin}/tls_clienthello_www_google_com.bin" \
            --new \
            --filter-tcp=80,443 \
            --dpi-desync=fake,multisplit \
            --dpi-desync-split-seqovl=664 \
            --dpi-desync-split-pos=1 \
            --dpi-desync-fooling=ts \
            --dpi-desync-repeats=8 \
            --dpi-desync-split-seqovl-pattern="${bin}/tls_clienthello_max_ru.bin" \
            --dpi-desync-fake-tls="${bin}/stun.bin" \
            --dpi-desync-fake-tls="${bin}/tls_clienthello_max_ru.bin" \
            --dpi-desync-fake-http="${bin}/tls_clienthello_max_ru.bin" \
            --daemon
        '';
        daemonPidFile = "/tmp/zapret.pid";
        inherit tinyproxyConfFile;
        tinyproxyPidFile = tp.pidFile;
      };
    }
  );
}
