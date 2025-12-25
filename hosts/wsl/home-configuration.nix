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
    tmux.prefixKey = "C-a";

    helix.enable = true;
    utils.enable = true;
    lazygit.enable = true;

    audio.disable-hsp = false;
    audio.disable-hw-volume = false;

    git = {
      enable = true;
      _1password = {
        enable = true;
        isWsl = true;
      };

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
}
