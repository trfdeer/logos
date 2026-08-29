{
  lib,
  pkgs,
  config,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
  hostName = "sol";
in
{
  imports = [
    profiles.hardware.devices.ss-fury

    (profiles.storage-layouts.makeStorageLayout {
      name = "nixos";
      device = config.sqwer.secrets.devices.ss-minipc.drive_paths.root;
      filesystem = "btrfs";
      encrypted = { };
      impermanent = false;
      subvolumes = profiles.storage-layouts.btrfsSubvols.root;
    })

  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking = {
    inherit hostName;
    domain = config.sqwer.secrets.outConfig."${hostName}".domain;

    networkmanager.enable = true;
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  sqwer.system = {
    boot.secureBoot.enable = true;

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
