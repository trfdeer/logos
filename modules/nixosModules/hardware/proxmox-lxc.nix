{ config, lib, ... }:
let
  cfg = config.sqwer.system.hardware.proxmox-lxc;
in
{
  options.sqwer.system.hardware.proxmox-lxc = {
    enable = lib.mkEnableOption "Is a proxmox lxc container";
  };

  config = lib.mkIf cfg.enable {
    proxmoxLXC = {
      privileged = true;
      manageNetwork = false;
      manageHostName = false;
    };

    systemd.network.wait-online.enable = false;
    systemd.additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
      };
    };
    security.pam.services.sshd.allowNullPassword = true;

    nix.settings = {
      sandbox = false;
    };
  };
}
