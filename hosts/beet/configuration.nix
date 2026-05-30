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
    (import profiles.storage-layouts.imperm-luks-esp {
      inherit lib;

      name = "nixos";
      device = "/dev/sda";
    })
    ./preservation.nix
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
        enable = lib.mkForce false;
        consoleMode = "max";
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
      pkiBundle = "/var/lib/sbctl/pki";
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
