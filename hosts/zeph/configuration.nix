{
  lib,
  pkgs,
  config,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
  hostName = "zeph";
in
{
  imports = [
    profiles.hardware.devices.desktop-zeph
    (profiles.storage-layouts.makeStorageLayout {
      name = "nixos";
      device = config.sqwer.secrets.devices.ll-comput.drive_paths.root;
      filesystem = "xfs";
      encrypted = { };
      impermanent = true;
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

    network = {
      enable = true;
      interface = "en*";
    };

    firewall = {
      enable = true;
      zones = {
        lan.allowedTCPPorts = [ 8080 ];
        mesh.allowedTCPPorts = [ 8080 ];
      };
    };

    tailscale = {
      enable = true;
      operator = id.username;
    };

    podman = {
      enable = true;
      users = [ id.username ];
    };
  };

  # (GPU monitoring tools removed; run them in a container if needed)
  # Firmware is curated in profiles/hardware/devices/desktop-gre.nix

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
