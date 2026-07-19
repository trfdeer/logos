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
    (import profiles.storage-layouts.imperm-luks-esp {
      inherit lib;

      name = "nixos";
      device = config.sqwer.secrets.devices.ll-comput.drive_paths.root;
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
    impermanence.enable = true;
    boot.secureBoot.enable = true;

    tailscale = {
      enable = true;
      operator = id.username;
    };

    podman.enable = true;

    libvirtd = {
      enable = true;
      users = [ id.username ];
    };
  };
  environment.systemPackages = with pkgs; [
    amdgpu_top
    rocmPackages.rocm-smi
  ];

  services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
