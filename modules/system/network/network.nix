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
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    services.resolved.enable = false;

    systemd.network = {
      enable = true;
      networks."${cfg.name}" = {
        matchConfig.Name = cfg.interface;
        networkConfig.DHCP = "yes";
      };
    };
  };
}
