{ lib, ... }:
{
  imports = [
    ./env.nix
    ./git.nix
    ./zsh.nix
    ./starship.nix
    ./direnv.nix
    ./tmux.nix
    ./helix.nix
    ./utils.nix
    ./sound.nix
    ./lazygit.nix
    ./devtools.nix
    ./catppuccin.nix
  ];

  config.sqwer = {
    env = {
      isWsl = lib.mkDefault false;
      has1Password = lib.mkDefault false;
    };

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
        name = lib.mkDefault "";
        email = lib.mkDefault "";
        signingkey = lib.mkDefault "";
      };
    };

    devtools = {
      basePath = lib.mkDefault "";
      go.enable = lib.mkDefault false;
      rust.enable = lib.mkDefault false;
    };

    catppuccin = {
      enable = lib.mkDefault true;
      flavor = lib.mkDefault "mocha";
    };

    sound = {
      disable-hsp = lib.mkDefault false;
      disable-hw-volume = lib.mkDefault false;
    };
  };

}
