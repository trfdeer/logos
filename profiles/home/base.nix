{ lib, config, ... }:
let
  id = config.logos.identity;
in
{
  home = {
    username = id.username;
    homeDirectory = "/home/${id.username}";
    stateVersion = config.logos.platform.stateVersion;
  };

  xdg.enable = true;
  xdg.mime.enable = true;
}
