{
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
