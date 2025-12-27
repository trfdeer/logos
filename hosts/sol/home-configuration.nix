{ constants, ... }:
{
  home = {
    username = constants.username;
    homeDirectory = "/home/${constants.username}";
    stateVersion = constants.stateVersion;
  };

  xdg.enable = true;
  xdg.mime.enable = true;

  sqwer = {
    git.user = {
      name = constants.name;
      email = constants.email;
      signingkey = constants.signingKey;
    };
  };
}
