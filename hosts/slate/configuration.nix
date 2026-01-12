{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  sqwer.system = {
    hardware.proxmox-lxc.enable = true;
    docker = {
      enable = true;
      useBtrfsDriver = false;
      users = [ id.username ];
    };
  };

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
