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
    profiles.hardware.devices.optiplex-7050
    ./preservation.nix

    (import profiles.storage-layouts.imperm-luks-esp {
      inherit lib;

      name = "nixos";
      device = config.sqwer.secrets.devices.op-server.drive_paths.root;
    })

    (import profiles.storage-layouts.btrfs-luks-data {
      inherit lib;

      name = "vault0";
      device = config.sqwer.secrets.devices.op-server.drive_paths.data;
    })
  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "brim";
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # Boot / storage (WSL + encrypted vault)
  # ------------------------------------------------------------
  boot = {
    bootspec.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      systemd.enable = true;
    };

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
      autoEnrollKeys.enable = true;
      pkiBundle = "/var/lib/sbctl/pki";
    };

    supportedFilesystems = [ "btrfs" ];
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  sqwer.system = {
    tailscale = {
      enable = true;
      operator = id.username;
    };
  };

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
