{
  lib,
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
  # Host-specific services
  # ------------------------------------------------------------
  sqwer.system = {
    impermanence.enable = true;
    boot.secureBoot.enable = true;

    tailscale = {
      enable = true;
      operator = id.username;
    };

    docker = {
      enable = true;
      useBtrfsDriver = true;
      enableRootless = true;
    };

    libvirtd = {
      enable = true;
      users = [ id.username ];
    };
  };

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
