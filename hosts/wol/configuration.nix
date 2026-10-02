{
  config,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  networking.hostName = "wol";
  sqwer.system = {
    podman.enable = true;
    podman.users = [ id.username ];
    ssh.enable = false;
  };

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
