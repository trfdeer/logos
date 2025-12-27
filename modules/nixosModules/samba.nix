{ lib, config, ... }:
{
  options.sqwer.samba = {
    enable = lib.mkEnableOption "Enable Samba file share";
    shareName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Share name";
    };
    shareUser = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Share path owner";
    };
    sharePath = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Share path";
    };
  };

  config = lib.mkIf config.sqwer.samba.enable {
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

        "${config.sqwer.samba.shareName}" = {
          "path" = config.sqwer.samba.sharePath;
          "browsable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = config.sqwer.samba.shareUser;
          "force group" = "users";
        };
      };
    };
  };
}
