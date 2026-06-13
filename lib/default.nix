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
  scanPaths = dir:
    let
      entries = builtins.readDir dir;
      keep = name:
        let type = entries.${name}; in
        (type == "regular" && builtins.match ".+\\.nix" name != null && name != "default.nix")
        || (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"));
    in
    builtins.map (name: dir + "/${name}")
      (builtins.filter keep (builtins.attrNames entries));
}
