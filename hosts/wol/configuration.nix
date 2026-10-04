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
    docker = {
      enable = true;
      users = [ id.username ];
    };
    ssh.enable = false;
  };

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
