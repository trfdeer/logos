{ constants, config, ... }:
{
  home = {
    username = constants.username;
    homeDirectory = "/home/${constants.username}";
    stateVersion = constants.stateVersion;
  };

  xdg.enable = true;
  xdg.mime.enable = true;

  sqwer = {
    zsh.enable = true;
    direnv.enable = true;
    starship.enable = true;
    tmux.enable = true;
    helix.enable = true;
    utils.enable = true;

    audio.disable-hsp = false;
    audio.disable-hw-volume = false;

    git = {
      enable = true;
      _1password.enable = false;

      user = {
        name = constants.name;
        email = constants.email;
        signingkey = constants.signingKey;
      };
    };

    devtools = {
      basePath = "${config.home.homeDirectory}/code";
      go.enable = false;
    };
  };

  programs.home-manager.enable = true;
}
