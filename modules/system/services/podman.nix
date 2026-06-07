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
      containers.enable = true;

      podman = {
        enable = true;
        dockerCompat = true;

        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [ podman-compose ];
    users.extraGroups.podman.members = cfg.users;
  };
}
