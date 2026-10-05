{
  lib,
  config,
  ...
}:
let
  id = config.logos.identity;
  cfg = config.logos.system.impermanence;
  isServer = lib.elem "server" config.logos.platform.roles;
in
{
  options.logos.system.impermanence = {
    enable = lib.mkEnableOption "Enable Secure Boot";
  };

  config = lib.mkIf cfg.enable {
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    preservation.enable = true;
    preservation.preserveAt."/persistent/nixos" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }

        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }

        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
      ];

      directories =
        [ ]
        ++ lib.optional config.logos.system.docker.enable "/var/lib/docker"
        ++ lib.optional config.logos.system.podman.enable "/var/lib/containers"
        ++ lib.optional config.logos.system.boot.secureBoot.enable "/var/lib/sbctl"
        ++ lib.optional config.logos.system.tailscale.enable "/var/lib/tailscale"
        ++ lib.optional isServer "/srv/containers";

      users.${id.username} = {
        files = [ ];
        directories =
          [ ]
          ++ lib.optional config.logos.system.docker.enable ".local/share/docker"
          ++ lib.optional config.logos.system.podman.enable ".local/share/containers";

      };
    };
  };
}
