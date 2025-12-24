{
  constants,
  lib,
  config,
  ...
}:
{
  home.username = constants.username;
  home.homeDirectory = "/home/${constants.username}";

  xdg.enable = lib.mkDefault true;
  xdg.mime.enable = lib.mkDefault true;
  # fonts.fontconfig.enable = true;

  sqwer = {
    zsh.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    utils.enable = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;

    audio.disable-hsp = lib.mkDefault false;
    audio.disable-hw-volume = lib.mkDefault false;

    git = {
      enable = lib.mkDefault true;
      _1password = {
        enable = lib.mkDefault true;
        isWsl = lib.mkDefault false;
      };
      user = {
        name = constants.name;
        email = constants.email;
        signingkey = constants.signingKey;
      };
    };

    devtools = {
      basePath = "${config.home.homeDirectory}/code";
      go.enable = lib.mkDefault true;
    };
  };

  home.stateVersion = constants.stateVersion;
  programs.home-manager.enable = true;
}
