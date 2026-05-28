{ config, lib, ... }:
let
  cfg = config.sqwer.system.hardware.proxmox-lxc;
in
{
  options.sqwer.system.hardware.proxmox-lxc = {
    enable = lib.mkEnableOption "Is a Proxmox LXC container";
    privileged = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is a privileged container";
    };
  };

  config = lib.mkIf cfg.enable {
    proxmoxLXC = {
      privileged = cfg.privileged;
      manageNetwork = false;
      manageHostName = false;
    };

    services.fstrim.enable = false; # Let Proxmox host handle fstrim
    systemd.network.wait-online.enable = false;
    systemd.additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];

    nix.settings = {
      sandbox = false;
    };
  };
}
