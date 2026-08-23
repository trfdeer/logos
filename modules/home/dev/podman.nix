{ lib, config, ... }:
let
  cfg = config.sqwer.home.podman;
in
{
  options.sqwer.home.podman = {
    enable = lib.mkEnableOption "Podman Configuration";
    useBtrfsDriver = lib.mkEnableOption "Use btrfs driver";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.sessionVariables = {
          PODMAN_COMPOSE_WARNING_LOGS = false;
        };
      }

      (lib.mkIf cfg.useBtrfsDriver {
        xdg.configFile."containers/storage.conf".text = ''
          [storage]
          driver = "btrfs"
          graphroot = "${config.xdg.dataHome}/containers/storage"
        '';
      })
    ]
  );
}
