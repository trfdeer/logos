{
  lib,
  config,
  ...
}:
let
  id = config.sqwer.identity;
  cfg = config.sqwer.system.impermanence;
in
{
  options.sqwer.system.impermanence = {
    enable = lib.mkEnableOption false;
  };

  config = lib.mkIf cfg.enable {
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    preservation.enable = true;
    preservation.preserveAt."/persistent" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
      ];

      directories = [

      ]
      ++ lib.optional config.sqwer.system.boot.secureBoot.enable "/var/lib/sbctl"
      ++ lib.optional config.sqwer.system.tailscale.enable "/var/lib/tailscale";

      users.${id.username} = {
        files = [ ];
        directories = [ ];
      };
    };
  };
}
