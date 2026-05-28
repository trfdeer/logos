{
  lib,
  pkgs,
  config,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
    profiles.hardware.vm.qemu-guest
    (import profiles.storage-layouts.btrfs-esp {
      inherit lib;

      name = "nixos";
      device = "/dev/sda";
    })
  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "beet";
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # Boot / storage (WSL + encrypted vault)
  # ------------------------------------------------------------
  boot = {
    bootspec.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.systemd.enable = true;

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "btrfs" ];
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  # sqwer.system = {
  #   tailscale = {
  #     enable = true;
  #     operator = id.username;
  #   };
  # };

  # services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
