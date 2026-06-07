{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  wsl = {
    enable = true;
    defaultUser = id.username;
  };

  sqwer = {
    platform.isWsl = true;
    system.boot.doNotConfigure = true;
  };
}
