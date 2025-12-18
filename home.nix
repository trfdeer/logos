{ constants, config, ... }:
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

    audio.disable-hsp = true;
    audio.disable-hw-volume = true;

    git = {
      enable = true;
      _1password.enable = true;
      user = {
        name = constants.name;
        email = constants.email;
        signingkey = constants.signingKey;
      };
    };

    devtools = {
      basePath = "${config.home.homeDirectory}/code";
      go.enable = true;
    };
  };

  home.stateVersion = constants.stateVersion;
  programs.home-manager.enable = true;
}
