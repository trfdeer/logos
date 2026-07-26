{ lib, config, ... }:
let
  id = config.sqwer.identity;
in
{
  home = {
    username = id.username;
    homeDirectory = "/home/${id.username}";
    stateVersion = config.sqwer.platform.stateVersion;
  };

  xdg.enable = true;
  xdg.mime.enable = true;
}
