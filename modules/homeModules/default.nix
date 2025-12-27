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
    ./audio.nix
    ./lazygit.nix
    ./devtools.nix
    ./catppuccin.nix
  ];

  config.sqwer = {
    catppuccin = {
      enable = lib.mkDefault true;
      flavor = lib.mkDefault "mocha";
    };
  };

}
