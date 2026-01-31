{
  config,
  pkgs,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
    profiles.hardware.vm.qemu-guest
    ./disko-configuration.nix
  ];

  networking = {
    hostName = "atlas";
    useDHCP = false;
    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "172.16.11.102";
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
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
