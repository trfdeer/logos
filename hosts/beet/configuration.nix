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
    profiles.hardware.vm.qemu-guest
    (import profiles.storage-layouts.imperm-luks-esp {
      inherit lib;

      name = "nixos";
      device = "/dev/sda";
    })
  ];

  # ------------------------------------------------------------
  # Host identity
  # ------------------------------------------------------------
  networking.hostName = "beet";
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # Boot / storage (WSL + encrypted vault)
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  sqwer.system = {
    impermanence.enable = true;
    boot.secureBoot.enable = true;

    #   tailscale = {
    #     enable = true;
    #     operator = id.username;
    #   };
  };

  # services.fstrim.enable = true;

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
