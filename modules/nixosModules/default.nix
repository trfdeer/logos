{
  standalone.hardware = {
    hyper-v = ./hardware/hyper-v.nix;
    proxmox-lxc = ./hardware/proxmox-lxc.nix;
  };

  sqwerSystem = {
    imports = [
      ./docker.nix

      ./network/tailscale.nix
      ./network/samba.nix
    ];
  };
}
