{ lib, config, ... }:
let
  cfg = config.sqwer.system.samba;
in
{
  options.sqwer.system.samba = {
    enable = lib.mkEnableOption "Enable Samba file share";

    name = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "";
      description = "Name of the Samba share.";
    };

    path = lib.mkOption {
      type = lib.types.path;
      default = "";
      description = "Filesystem path to be shared via Samba.";
    };

    owner = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "";
      description = "User that owns the shared path.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowPing = true;
    };

    services.samba = {
      enable = true;
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          "hosts allow" = "100.64.0.0/10 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "Bad User";
        };

        "${cfg.name}" = {
          "path" = cfg.path;
          "browsable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = cfg.owner;
          "force group" = "users";
        };
      };
    };
  };
}
