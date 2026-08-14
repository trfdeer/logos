{ lib, config, ... }:
let
  cfg = config.sqwer.home.podman;
in
{
  options.sqwer.home.podman = {
    enable = lib.mkEnableOption "Podman Configuration";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."containers/containers.conf".text = ''
      [containers]
      userns = "auto"
    '';

    xdg.configFile."containers/storage.conf".text = ''
      [storage]
      driver = "btrfs"
      graphroot = "${config.xdg.dataHome}/containers/storage"
    '';
  };
}
