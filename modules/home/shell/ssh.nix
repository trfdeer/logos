{ lib, config, ... }:
let
  cfg = config.sqwer.home.ssh;
  cfgOp = config.sqwer.home._1password;
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
            identityFiles = lib.mkOption {
              type = lib.types.listOf lib.types.nonEmptyStr;
              description = "One or more SSH identity files for this host.";
            };
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

      includes = [ ] ++ lib.optional cfgOp.enable "~/.ssh/1Password/config";

      settings = lib.mkMerge [
        (lib.mkIf cfgOp.enable {
          "*" = {
            IdentityAgent = "~/.1password/agent.sock";
          };
        })

        (lib.mapAttrs (
          name: host:
          {
            HostName = host.domain;
            User = host.user;
          }
          // (lib.optionalAttrs (!cfgOp.enable) {
            IdentityFile = lib.imap0 (
              i: idFileName: "${config.home.homeDirectory}/.ssh/${idFileName}"
            ) host.identityFiles;
            IdentitiesOnly = true;
          })
        ) effectiveHosts)
      ];
    };
  };
}
