{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-2745eb6c-1584-4b93-9720-2eade3ed7509";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-2745eb6c-1584-4b93-9720-2eade3ed7509".device =
    "/dev/disk/by-uuid/2745eb6c-1584-4b93-9720-2eade3ed7509";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CC62-31B4";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
