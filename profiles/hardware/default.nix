{
  vm = {
    hyperv = ./vm/hyper-v.nix;
    vmware = ./vm/vmware.nix;
    qemu-guest = ./vm/qemu-guest.nix;
  };

  ct = {
    proxmox-lxc = ./ct/proxmox-lxc.nix;
  };

  devices = {
    ss-fury = ./devices/ss-fury.nix;
    dell-precision-3561 = ./devices/dell-precision-3561.nix;
  };
}
