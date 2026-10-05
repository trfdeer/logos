{
  lib,
  config,
  profiles,
  ...
}:
let
  id = config.logos.identity;
  hostName = "star";
  hostCfg = config.logos.secrets.outConfig."${hostName}";
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
    domain = config.logos.secrets.outConfig."${hostName}".domain;
  };

  # ------------------------------------------------------------
  # Host-specific services
  # ------------------------------------------------------------
  logos.system = {
    impermanence.enable = true;

    boot.initrdSsh = {
      enable = true;
      port = 22;
      hostKey = "/persistent/nixos/etc/ssh/initrd_host_ed25519_key";
      publicFallback = false;

      network = lib.mkIf (hostCfg.network != null) hostCfg.network;

      tailscale = {
        enable = true;
        stateDir = "/persistent/nixos/var/lib/tailscale-initrd";
        ip = hostCfg.initrdSsh.bindIp;
      };
    };

    firewall = {
      enable = true;
      zones = {
        lan = {
          match.interfaces = [ "en*" ];
          allowedTCPPorts = [ ];
          allowedUDPPorts = [ ];
        };
        mesh = {
          allowedTCPPorts = [
            22
            53
            80
            443
            2222
          ];
          allowedUDPPorts = [
            53
            443
          ];
        };
      };
    };

    network = {
      enable = true;
      interface = "en*";
      static = {
        ipv4Address = hostCfg.network.manualConfiguration.address;
        ipv4Gateway = hostCfg.network.manualConfiguration.gateway;

        ipv6Address = hostCfg.networkV6.manualConfiguration.address;
        ipv6Gateway = hostCfg.networkV6.manualConfiguration.gateway;

        dns = [ ] ++ hostCfg.network.manualConfiguration.dns ++ hostCfg.networkV6.manualConfiguration.dns;
      };
    };

    ssh.enable = true;

    tailscale = {
      enable = true;
      operator = id.username;
    };

    ssh.port = 2222;
  };

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
