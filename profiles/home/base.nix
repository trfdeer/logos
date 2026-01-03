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

  sqwer.home = {
    zsh.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    tmux = {
      enable = lib.mkDefault true;
      prefixKey = lib.mkDefault "C-a";
    };

    utils.enable = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;

    git = {
      enable = lib.mkDefault true;
      user = {
        name = id.fullName;
        email = id.email;
        signingkey = id.gitSshPublicKey;
      };
    };

    catppuccin = {
      enable = lib.mkDefault true;
      flavor = lib.mkDefault "mocha";
    };

    nix.enable = lib.mkDefault true;
  };
}
