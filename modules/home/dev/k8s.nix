{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.k8s;
in
{
  options.sqwer.home.k8s = {
    enable = lib.mkEnableOption "Enable Kubernetes tools";
    clusterPackage = lib.mkPackageOption pkgs.unstable "k3d" {
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
