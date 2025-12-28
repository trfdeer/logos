{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  home = {
    username = id.username;
    homeDirectory = "/home/${id.username}";
    stateVersion = "25.11";
  };

  xdg.enable = true;
  xdg.mime.enable = true;

  sqwer = {
    git.user = {
      name = id.fullName;
      email = id.email;
      signingkey = id.gitSshPublicKey;
    };
  };
}
