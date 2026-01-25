{
  standalone.hardware = {
    hyper-v = ./hardware/hyper-v.nix;
    proxmox-lxc = ./hardware/proxmox-lxc.nix;
    vmware = ./hardware/vmware.nix;
  };

  sqwerSystem = {
    imports = [
      ./network/tailscale.nix
      ./network/samba.nix

      ./games/terraria.nix
      ./games/minecraft.nix

      ./services/docker.nix
      ./services/ssh.nix
    ];
  };
}
