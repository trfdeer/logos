{
  config,
  ...
}:
let
  id = config.logos.identity;
in
{
  networking.hostName = "syf";
  # Secret Service provider for headless WSL
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  logos.system = {
    podman = {
      enable = true;
      users = [ id.username ];
    };
    ssh.enable = false;
  };

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
