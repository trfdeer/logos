{
  standalone.hardware = {
    proxmox-lxc = ./hardware/proxmox-lxc.nix;
  };

  sqwerSystem = {
    imports = [
      ./network/tailscale.nix
      ./network/samba.nix

      ./games/terraria.nix
      ./games/minecraft.nix

      ./services/docker.nix
      ./services/ssh.nix
      ./services/libvirtd.nix

      ./kde.nix
      ./core/impermanence.nix
      ./core/boot.nix
      ./utils/_1password.nix
    ];
  };
}
