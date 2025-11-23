{ constants, ... }:
{
  home.username = constants.username;
  home.homeDirectory = "/home/${constants.username}";

  xdg.enable = true;
  xdg.mime.enable = true;
  # fonts.fontconfig.enable = true;

  sqwer = {
    zsh.enable = true;
    direnv.enable = true;
    starship.enable = true;
    tmux.enable = true;
    helix.enable = true;
    utils.enable = true;

    git.enable = true;
  };

  home.stateVersion = constants.stateVersion;
  programs.home-manager.enable = true;
}
