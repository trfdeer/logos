{ lib, config, ... }:
let
  cfg = config.sqwer.system.docker;
in
{
  options.sqwer.system.docker = {
    enable = lib.mkEnableOption "Enable docker";
    useBtrfsDriver = lib.mkEnableOption "Use btrfs storage driver";
    enableRootless = lib.mkEnableOption "Use rootless docker";
    openSwarmPorts = lib.mkEnableOption "Open swarm ports (2377, 7946, 4789)";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = ''
        List of users to be added to `docker` group.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        virtualisation.docker = {
          enable = true;
          storageDriver = lib.mkIf cfg.useBtrfsDriver "btrfs";
        };

        users.extraGroups.docker.members = cfg.users;
      }
      (lib.mkIf (cfg.enableRootless) {
        # Have to enable per user with `systemctl --user enable --now docker`

        virtualisation.docker.rootless = {
          enable = true;
          setSocketVariable = true;
        };

        boot.kernel.sysctl = {
          "net.ipv4.ip_unprivileged_port_start" = 22;
        };
      })
      (lib.mkIf (cfg.openSwarmPorts) {
        networking.firewall.allowedTCPPorts = [
          2377
          7946
        ];

        networking.firewall.allowedUDPPorts = [
          7946
          4789
        ];
      })
    ]
  );
}
