{
  lib,
  config,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
  hostName = "brim";
in
{
  imports = [
    profiles.hardware.devices.optiplex-7050

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
  networking = {
    inherit hostName;
    domain = config.sqwer.secrets.outConfig."${hostName}".domain;
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  sqwer.system = {
    impermanence.enable = true;
    boot.secureBoot.enable = true;

    network = {
      enable = true;
      interface = "en*";
    };

    tailscale = {
      enable = true;
      operator = id.username;
    };

    podman.enable = true;
  };

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
