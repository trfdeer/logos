{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.sqwer.system.cockpit;
in
{
  options.sqwer.system.cockpit = {
    enable = lib.mkEnableOption "Enable cockpit";
  };

  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      showBanner = false;

      port = 9090;
      openFirewall = false;

      plugins =
        with pkgs;
        [
          cockpit-files
        ]
        ++ lib.optional config.sqwer.system.libvirtd.enable pkgs.cockpit-machines
        ++ lib.optional config.sqwer.system.podman.enable pkgs.cockpit-podman;
    };
  };
}
