{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  sqwer.system.hardware.proxmox-lxc = {
    enable = true;
    privileged = lib.mkDefault false;
  };
}
