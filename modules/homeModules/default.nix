{ lib, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./starship.nix
    ./direnv.nix
    ./tmux.nix
    ./helix.nix
    ./utils.nix
    ./sound.nix
    ./lazygit.nix
    ./session.nix
    ./catppuccin.nix
  ];

  config.sqwer = {
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
