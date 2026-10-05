{ lib, config, ... }:
let
  id = config.logos.identity;
in
{
  logos.system = {
    ssh.enable = lib.mkDefault true;
    _1password = {
      enable = true;
      systemUsers = [ id.username ];
    };
  };
}
