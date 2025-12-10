{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.kube = {
    enable = mkEnableOption "enable kube";
  };

  config = mkIf config.kube.enable {
    # Maybe add selfsustain for k3s? Dunno minikube for dev is enough
    environment.systemPackages = with pkgs; [
      helm
      k9s
      kompose
      kubectl
      minikube
    ];
  };
}
