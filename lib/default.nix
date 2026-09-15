{
  # Generate a tinyproxy config for a network namespace proxy.
  # Returns { conf, pidFile } — use conf as the option default and
  # pidFile in the stop command so both stay in sync.
  mkTinyproxyConf =
    {
      name,
      port,
      listenIp,
      allowIps,
    }:
    let
      pidFile = "/tmp/${name}-tinyproxy.pid";
    in
    {
      inherit pidFile;
      conf = ''
        User nobody
        Group nogroup
        Port ${toString port}
        Listen ${listenIp}
        Timeout 600
        ${builtins.concatStringsSep "\n" (map (ip: "Allow ${ip}") allowIps)}
        PidFile "${pidFile}"
      '';
    };

  # Collect all importable paths in dir (one level deep):
  # - .nix files, excluding default.nix itself
  # - subdirectories that have a default.nix
  scanPaths =
    dir:
    let
      entries = builtins.readDir dir;
      keep =
        name:
        let
          type = entries.${name};
        in
        (type == "regular" && builtins.match ".+\\.nix" name != null && name != "default.nix")
        || (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"));
    in
    builtins.map (name: dir + "/${name}") (builtins.filter keep (builtins.attrNames entries));

  # Shared scaffolding for the routed-netns proxy services (zapret,
  # zapret2): veth pair into the namespace, NAT for the /30, mangle
  # NFQUEUE plumbing, tinyproxy, and matching teardown. The module-specific
  # DPI daemon and its arguments are passed through as strings.
  mkNetnsProxyService =
    pkgs:
    {
      name,
      hostVethIp,
      nsVethIp,
      subnet,
      qnum,
      # list of { proto, ports ? null, connbytes ? true }
      nfqRules,
      # bash snippet executed inside the netns (the DPI daemon)
      daemonCmd,
      daemonPidFile,
      tinyproxyConfFile,
      tinyproxyPidFile,
      extraDown ? "",
    }:
    let
      optional = cond: x: if cond then [ x ] else [ ];
      mkNfqRule =
        {
          proto,
          ports ? null,
          connbytes ? true,
        }:
        builtins.concatStringsSep " " (
          [
            "${pkgs.iproute2}/bin/ip netns exec ${name} ${pkgs.iptables}/bin/iptables"
            "-t mangle -A OUTPUT -o ${name}-veth1"
            "-p ${proto}${if ports == null then "" else " --dport ${ports}"}"
          ]
          ++ optional connbytes "-m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6"
          ++ [
            "-m mark ! --mark 0x40000000/0x40000000"
            "-j NFQUEUE --queue-num ${toString qnum} --queue-bypass"
          ]
        );
    in
    {
      description = "${name} netns";
      bindsTo = [ "netns@${name}.service" ];
      requires = [ "network-online.target" ];
      after = [ "netns@${name}.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;

        ExecStart =
          with pkgs;
          writers.writeBash "${name}-up" ''
            set -e

            ${iproute2}/bin/ip link add ${name}-veth0 type veth peer name ${name}-veth1
            ${iproute2}/bin/ip link set ${name}-veth1 netns ${name}

            ${iproute2}/bin/ip addr add ${hostVethIp}/30 dev ${name}-veth0
            ${iproute2}/bin/ip link set ${name}-veth0 up

            ${iproute2}/bin/ip -n ${name} addr add ${nsVethIp}/30 dev ${name}-veth1
            ${iproute2}/bin/ip -n ${name} link set ${name}-veth1 up
            ${iproute2}/bin/ip -n ${name} link set lo up

            ${iproute2}/bin/ip -n ${name} route add default via ${hostVethIp}

            ${iptables}/bin/iptables -t nat -A POSTROUTING -s ${subnet}/30 -j MASQUERADE

            # Early connection packets -> the DPI daemon's NFQUEUE
            ${builtins.concatStringsSep "\n\n            " (map mkNfqRule nfqRules)}

            ${daemonCmd}

            ${iproute2}/bin/ip netns exec ${name} ${tinyproxy}/bin/tinyproxy -c ${tinyproxyConfFile}
          '';
        ExecStop =
          with pkgs;
          writers.writeBash "${name}-down" ''
            # Remove host-netns NAT rule
            ${iptables}/bin/iptables -t nat -D POSTROUTING -s ${subnet}/30 -j MASQUERADE

            ${extraDown}

            # Remove the veth pair (both ends go away automatically)
            ${iproute2}/bin/ip link del ${name}-veth0

            # Kill daemons; mangle rules inside the netns are cleaned up
            # automatically when the netns@ service destroys the namespace
            ${procps}/bin/pkill -F ${tinyproxyPidFile} || true
            ${procps}/bin/pkill -F ${daemonPidFile} || true
          '';
      };
    };

  # Fixed-path sudo helper for running a command inside a network namespace
  # as the *invoking* user. The sudoers rule grants exactly the immutable
  # store path (any args); the wrapper drops back to SUDO_USER inside the
  # netns, so the worst case is "any command as yourself inside the netns" —
  # never the passwordless root that an `ip netns exec <ns> *` wildcard
  # granted before.
  mkNetnsExec =
    pkgs: name:
    let
      helper = pkgs.writeShellScriptBin "netns-exec-${name}" ''
        set -euo pipefail
        # Only meaningful when reached through sudo; SUDO_USER names the
        # unprivileged caller we re-drop to.
        if [ -z "''${SUDO_USER:-}" ]; then
          echo "netns-exec-${name}: refusing to run outside sudo" >&2
          exit 1
        fi
        # sudo's secure_path lacks the per-user profile (home-manager with
        # useUserPackages); restore it for the dropped-to command.
        export PATH="/etc/profiles/per-user/$SUDO_USER/bin:$PATH"
        exec ${pkgs.iproute2}/bin/ip netns exec ${name} \
          ${pkgs.util-linux}/bin/runuser -u "$SUDO_USER" -- "$@"
      '';
    in
    {
      inherit helper;
      run = pkgs.writeShellScriptBin "${name}-run" ''
        set -euo pipefail

        if [ $# -eq 0 ]; then
          echo "Usage: ${name}-run <command> [args...]"
          exit 1
        fi

        if ! ${pkgs.iproute2}/bin/ip netns list | grep -qE "^${name}( |$)"; then
          echo "${name} netns not running"
          exit 1
        fi

        exec /run/wrappers/bin/sudo ${helper}/bin/netns-exec-${name} "$@"
      '';
      # Exact-path NOPASSWD rule — no wildcard, no SETENV (SETENV on a bash
      # wrapper would allow BASH_ENV injection into the root interpreter).
      sudoRule = {
        commands = [
          {
            command = "${helper}/bin/netns-exec-${name}";
            options = [ "NOPASSWD" ];
          }
        ];
      };
      # Command-scoped sudoers Defaults: keep the display vars env_reset
      # scrubs, so GUI apps still work inside the namespace.
      sudoEnvKeep = ''
        Defaults!${helper}/bin/netns-exec-${name} env_keep += "WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY XAUTHORITY"
      '';
    };
}
