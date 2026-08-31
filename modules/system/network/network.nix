{ lib, config, ... }:
let
  cfg = config.sqwer.system.network;
in
{
  options.sqwer.system.network = {
    enable = lib.mkEnableOption "networking configuration";

    name = lib.mkOption {
      type = lib.types.str;
      default = "10-lan";
      description = ''
        The name of the network configuration.
      '';
    };

    interface = lib.mkOption {
      type = lib.types.str;
      description = ''
        The network interface to use for the system.
      '';
    };

    static = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            ipv4Address = lib.mkOption {
              type = lib.types.str;
              example = "192.168.1.10/24";
              description = ''
                Static IPv4 address and prefix length.
              '';
            };

            ipv4Gateway = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "192.168.1.1";
              description = ''
                Static IPv4 gateway.
              '';
            };

            ipv6Address = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Static IPv6 address and prefix length.
              '';
            };

            ipv6Gateway = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Static IPv6 gateway.
              '';
            };

            dns = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                DNS servers to use with a static configuration.
              '';
            };
          };
        }
      );
      default = null;
      description = ''
        Use a manual static IP configuration instead of DHCP.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    services.resolved.enable = false;

    systemd.network = {
      enable = true;
      networks."${cfg.name}" = {
        matchConfig.Name = cfg.interface;
        networkConfig = {
          DHCP = if cfg.static == null then "yes" else "no";
          LinkLocalAddressing = "no";
        };
        address =
          if cfg.static == null then
            [ ]
          else
            (
              lib.optional (cfg.static.ipv4Address != "") cfg.static.ipv4Address
              ++ lib.optional (cfg.static.ipv6Address != null) cfg.static.ipv6Address
            );
        routes =
          lib.optional (cfg.static != null && cfg.static.ipv4Gateway != null) {
            Gateway = cfg.static.ipv4Gateway;
          }
          ++ lib.optional (cfg.static != null && cfg.static.ipv6Gateway != null) {
            Gateway = cfg.static.ipv6Gateway;
          };
        dns = if cfg.static == null then [ ] else cfg.static.dns;
      };
    };
  };
}
