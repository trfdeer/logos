{ lib, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
