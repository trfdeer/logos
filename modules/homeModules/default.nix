{ ... }:
{
  imports = [
    ./shell/zsh.nix
    ./shell/tmux.nix
    ./shell/direnv.nix
    ./shell/starship.nix

    ./dev/git.nix
    ./dev/helix.nix
    ./dev/lazygit.nix
    ./dev/session_vars.nix

    ./misc/nix.nix
    ./misc/utils.nix
    ./misc/catppuccin.nix

    ./desktop/sound.nix
  ];
}
