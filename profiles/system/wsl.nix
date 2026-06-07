{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  wsl = {
    enable = true;
    defaultUser = id.username;

    ssh-agent = {
      enable = true;
      users = [ id.username ];
    };
  };

  sqwer = {
    platform.isWsl = true;
    system.boot.doNotConfigure = true;
  };
}
