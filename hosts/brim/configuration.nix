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

    (profiles.storage-layouts.makeStorageLayout {
      name = "nixos";
      device = config.sqwer.secrets.devices.op-server.drive_paths.root;
      filesystem = "xfs";
      encrypted = true;
      impermanent = false;
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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
