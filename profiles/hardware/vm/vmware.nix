{ config, lib, ... }:

let
  cfg = config.sqwer.system.hardware.vmware;
in
{
  options.sqwer.system.hardware.vmware = {
    enable = lib.mkEnableOption "Is a VMWare VM";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.vmware.guest.enable = true;
  };
}
