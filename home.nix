{ constants, ... }:
{
  home.username = constants.username;
  home.homeDirectory = "/home/${constants.username}";
  xdg.enable = true;

  sqwer = {
    git.enable = true;
  };

  home.stateVersion = constants.stateVersion;
  programs.home-manager.enable = true;
}
