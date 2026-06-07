{
  config,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  sqwer.system = {
    podman = {
      enable = true;
      users = [ id.username ];
    };
    ssh.enable = false;
  };

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
