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
    profiles.hardware.devices.ss-fury

    (import profiles.storage-layouts.btrfs-luks-esp {
      inherit lib;

      name = "nixos";
      device = config.sqwer.secrets.devices.ss-minipc.drive_paths.root;
    })

    (import profiles.storage-layouts.btrfs-luks-data {
      inherit lib;

      name = "vault0";
      device = config.sqwer.secrets.devices.ss-minipc.drive_paths.data;
    })

  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "sol";
  networking.networkmanager.enable = true;

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
