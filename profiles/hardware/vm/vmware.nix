{ config, lib, ... }:

let
  cfg = config.logos.system.hardware.vmware;
in
{
  options.logos.system.hardware.vmware = {
    enable = lib.mkEnableOption "Is a VMWare VM";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.vmware.guest.enable = true;
  };
}
