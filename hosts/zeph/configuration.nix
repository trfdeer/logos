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
    boot.secureBoot.enable = true;

    network = {
      enable = true;
      interface = "en*";
    };

    tailscale = {
      enable = true;
      operator = id.username;
    };

    docker = {
      enable = true;
      enableRootless = true;
      useBtrfsDriver = true;
      users = [ id.username ];
    };
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    rocmPackages.rocm-smi
  ];

  services.fstrim.enable = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
