{ lib, config, ... }:
{
  options = {
    sqwer.incus.enable = lib.mkEnableOption "Enable incus";
    sqwer.incus.adminUser = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Incus admin user";
    };
  };

  config = lib.mkIf config.sqwer.incus.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;
      preseed = {
        networks = [
          {
            config = {
              "ipv4.address" = "172.16.1.1/24";
              "ipv4.nat" = "true";
            };
            name = "incusbr0";
            type = "bridge";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                size = "35GiB";
                type = "disk";
              };
            };
            name = "default";
          }
        ];
        storage_pools = [
          {
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
            driver = "dir";
            name = "default";
          }
        ];
      };
    };

    users.users.${config.sqwer.incus.adminUser}.extraGroups = [ "incus-admin" ];

    networking.nftables.enable = true;
    networking.firewall.allowedTCPPorts = [ 443 ];
    networking.firewall.interfaces.incusbr0 = {
      allowedTCPPorts = [
        53
        67
      ];
      allowedUDPPorts = [
        53
        67
      ];
    };
  };
}
