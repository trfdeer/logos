{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.k8s;
in
{
  options.logos.home.k8s = {
    enable = lib.mkEnableOption "Enable Kubernetes tools";
    clusterPackage = lib.mkPackageOption pkgs.unstable "talosctl" {
      nullable = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs.unstable;
      [
        k9s
        kubectl
        kubernetes-helm
      ]
      ++ lib.optional (cfg.clusterPackage != null) cfg.clusterPackage;
  };
}
