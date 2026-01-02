{
  config,
  hostname,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  wsl.enable = true;
  wsl.defaultUser = id.username;

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];

  networking.hostName = hostname;
}
