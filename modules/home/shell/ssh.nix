{ lib, config, ... }:
let
  cfg = config.sqwer.home.ssh;
  id = config.sqwer.identity;

  filteredIdentityHosts =
    if cfg.strict then
      lib.filterAttrs (name: _: lib.elem name cfg.hostFilter) id.sshHosts
    else if cfg.hostFilter == [ ] then
      id.sshHosts
    else
      lib.filterAttrs (name: _: lib.elem name cfg.hostFilter) id.sshHosts;

  effectiveHosts = filteredIdentityHosts // cfg.additionalHosts;
in
{
  options.sqwer.home.ssh = {
    enable = lib.mkEnableOption "Enable SSH config derived from identity";

    strict = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Require explicit hostFilter; default to none.";
    };

    hostFilter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Names of identity SSH hosts to enable on this machine.
        Empty means all identity SSH hosts.
      '';
    };

    additionalHosts = lib.mkOption {
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
      description = ''
        Machine-local SSH hosts not part of global identity.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = lib.mkMerge [
        ({
          "*" = {
            forwardAgent = true;
          };
        })
        (lib.mapAttrs (name: host: {
          hostname = host.domain;
          user = host.user;
          identityFile = "${config.home.homeDirectory}/.ssh/${name}.pub";
          identitiesOnly = true;
        }) effectiveHosts)
      ];
    };

    home.file = lib.mapAttrs' (name: host: {
      name = ".ssh/${name}.pub";
      value.text = host.sshPubKey;
    }) effectiveHosts;
  };
}
