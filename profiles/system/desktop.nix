{ lib, config, ... }:
let
  id = config.sqwer.identity;
in
{
  sqwer.system = {
    ssh.enable = lib.mkDefault true;
    _1password = {
      enable = true;
      systemUsers = [ id.username ];
    };
  };
}
