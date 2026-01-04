{
  lib,
  pkgs,
  config,
  hostname,
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
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # Boot / storage
  # ------------------------------------------------------------
  boot = {
    bootspec.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      systemd.enable = true;
    };

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

  sqwer.system = {
    hardware.hyperv.enable = true;
  };

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
