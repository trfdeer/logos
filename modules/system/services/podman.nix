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
    useBtrfsDriver = lib.mkEnableOption "Use btrfs driver";
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
        # podman 5 defaults to the netavark network backend; CNI plugins are unused
        containersConf.cniPlugins = lib.mkForce [ ];
        storage.settings.storage =
          { }
          // (lib.optionalAttrs cfg.useBtrfsDriver {
            driver = "btrfs";
            graphroot = "/var/lib/containers/storage";
            runroot = "/run/containers/storage";
          });
      };

      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;

        # crun is already bundled with podman; drop the default runc runtime
        extraRuntimes = [ ];
        # krun support drags in libkrun/libkrunfw
        package = pkgs.podman.override {
          crun = pkgs.crun.override { withLibkrun = false; };
        };
      };
    };

    users.extraGroups.podman.members = cfg.users;

    users.users = lib.genAttrs cfg.users (_: {
      subUidRanges = [
        {
          startUid = 100000;
          count = 1048576;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 1048576;
        }
      ];
    });

    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 22;
    };
  };
}
