{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.system.podman;
in
{
  options.sqwer.system.podman = {
    enable = lib.mkEnableOption "Enable Podman";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      description = "Users to add to podman group.";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings = {
          containers.userns = "auto";
        };
        storage.settings.storage = {
          driver = "btrfs";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };

      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [ docker-compose ];
    users.extraGroups.podman.members = cfg.users;

    users.users = lib.getAttrs cfg.users (_: {
      subUidRanges = [
        {
          startUid = 100000;
          count = 1048576;
        }
      ];
      subGidRanges = [
        {
          startUid = 100000;
          count = 1048576;
        }
      ];
    });

    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };
  };
}
