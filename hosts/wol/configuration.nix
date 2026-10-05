{
  config,
  ...
}:
let
  id = config.logos.identity;
in
{
  networking.hostName = "wol";
  logos.system = {
    podman = {
      enable = true;
      users = [ id.username ];
    };
    ssh.enable = false;
  };

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
