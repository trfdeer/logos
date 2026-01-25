{ config, pkgs, ... }:
let
  id = config.sqwer.identity;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
  ];

  networking = {
    hostName = "atlas";
    useDHCP = false;
    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "172.16.11.4";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "172.16.11.1";
      interface = "ens18";
    };
  };

  boot = {
    bootspec.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "btrfs" ];
  };

  sqwer.system = {
    tailscale = {
      enable = true;
      acceptRoutes = false;
      operator = id.username;
    };

    docker = {
      enable = true;
      useBtrfsDriver = true;
      users = [ id.username ];
    };

    games.terraria = {
      enable = true;
      dataDir = "/srv/games/terraria";
      noUPnP = true;
      openFirewall = true;
      groupMembers = [ id.username ];

      instances.world_m1 = {
        enable = true;
        maxPlayers = 4;
        memoryMax = "1.5G";
        cpuQuota = "50%";
        worldSize = "medium";
        port = 7777;
      };
    };

    games.minecraft = {
      enable = true;
      groupMembers = [ id.username ];
      plugins = with pkgs.sqpkgs.minecraftPlugins; [
        geysermc
        floodgate
      ];
    };
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
