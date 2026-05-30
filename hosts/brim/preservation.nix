{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
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
        "/var/lib/sbctl"
        "/var/lib/tailscale"
      ];

      users.${id.username} = {
        files = [ ];

        directories = [ ];
      };
    };
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
