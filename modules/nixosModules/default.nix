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

      ./kde.nix
      ./utils/_1password.nix
    ];
  };
}
