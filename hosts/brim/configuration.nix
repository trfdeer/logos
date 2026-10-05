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
      encrypted = { };
      impermanent = false;
    })
  ];

  # No GPU/wifi on this box: skip redistributable firmware blobs
  # (facter enables them defensively for undetected devices)
  hardware.enableRedistributableFirmware = false;

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

    podman.enable = true;

    network = {
      enable = true;
      interface = "en*";
    };

    firewall = {
      enable = true;
      zones = {
        lan = {
          match.interfaces = [ "en*" ];
          allowedTCPPorts = [
            2222
            53
            80
            443
          ];
          allowedUDPPorts = [
            53
            443
          ];
        };
        mesh = {
          allowedTCPPorts = [
            2222
            53
            80
            443
          ];
          allowedUDPPorts = [
            53
            443
          ];
        };
      };
    };

    tailscale = {
      enable = true;
      operator = id.username;
    };

    ssh.port = 2222;
  };

  services.fstrim.enable = true;

  # Home Manager deltas come from the server home profile
}
