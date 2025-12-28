{
  lib,
  pkgs,
  config,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "sol";
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # Boot / storage (WSL + encrypted vault)
  # ------------------------------------------------------------
  boot = {
    bootspec.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      luks.devices.vault = {
        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b402b400e-part1";
        name = "vault-crypt";
        allowDiscards = true;
      };
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

    # Run `nix run nixpkgs#sbctl -- enroll-keys -m` after first boot while in setup mode.
    lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      pkiBundle = "/etc/secureboot";
    };

    supportedFilesystems = [ "btrfs" ];
  };

  fileSystems."/srv/vault" = {
    device = "/dev/mapper/vault";
    fsType = "btrfs";
    options = [
      "subvol=@vault"
      "ssd"
      "space_cache=v2"
      "compress=zstd"
      "noatime"
    ];
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  sqwer = {
    tailscale = {
      enable = true;
      operator = id.username;
      advertiseRoutes = "172.16.10.0/24";
    };

    samba = {
      enable = true;
      name = "vault";
      path = "/vault";
      owner = id.username;
    };
  };

  services.openssh.enable = true;
  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
