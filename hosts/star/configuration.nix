{
  lib,
  config,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
  hostName = "star";
  hostSecrets = config.sqwer.secrets.outConfig."${hostName}";
in
{
  imports = [
    profiles.hardware.vm.vps01

    (profiles.storage-layouts.makeStorageLayout {
      name = "nixos";
      device = "/dev/vda";
      filesystem = "xfs";
      encrypted = {
        method = "ssh";
      };
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

    boot.initrdSsh = {
      enable = true;
      port = 2222;
      hostKey = "/persistent/nixos/etc/ssh/initrd_host_ed25519_key";

      network = lib.mkIf (hostSecrets.initrdNetwork != null) hostSecrets.initrdNetwork;

      tailscale = {
        enable = true;
        stateDir = "/persistent/nixos/var/lib/tailscale-initrd";
        ip = hostSecrets.initrdTailscaleIp;
      };
    };

    network = {
      enable = true;
      interface = "en*";
    };

    ssh.enable = true;

    tailscale = {
      enable = true;
      operator = id.username;
    };
  };

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
