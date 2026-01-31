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
    profiles.hardware.devices.dell-precision-3561
    ./disko-configuration.nix
  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "rock";
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
      pkiBundle = "/etc/secureboot";
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

    ssh.enable = false;
  };

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
