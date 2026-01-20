{ lib, config, ... }:
let
  cfg = config.sqwer.system.docker;
in
{
  options.sqwer.system.docker = {
    enable = lib.mkEnableOption "Enable docker";
    useBtrfsDriver = lib.mkEnableOption "Use btrfs storage driver";
    rootless.enable = lib.mkEnableOption "Use rootless docker";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = ''
        List of users to be added to `docker` group.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = lib.mkIf cfg.useBtrfsDriver "btrfs";

      # Have to enable per user with `systemctl --user enable --now docker`
      rootless = lib.mkIf cfg.rootless.enable {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.extraGroups.docker.members = cfg.users;

  };
}
