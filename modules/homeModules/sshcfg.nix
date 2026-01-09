{ lib, config, ... }:
let
  cfg = config.sqwer.home.sshcfg;
in
{
  options.sqwer.home.sshcfg = {
    enable = lib.mkEnableOption "Enable ssh config";
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            domain = lib.mkOption { type = lib.types.nonEmptyStr; };
            user = lib.mkOption { type = lib.types.nonEmptyStr; };
            sshPubKey = lib.mkOption { type = lib.types.nonEmptyStr; };
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = lib.mapAttrs (name: host: {
        hostname = host.domain;
        user = host.user;
        identityFile = "${config.home.homeDirectory}/.ssh/${name}.pub";
        identitiesOnly = true;
      }) cfg.hosts;
    };

    home.file = lib.mapAttrs' (name: host: {
      name = "${config.home.homeDirectory}/.ssh/${name}.pub";
      value = {
        text = host.sshPubKey;
      };
    }) cfg.hosts;
  };
}
