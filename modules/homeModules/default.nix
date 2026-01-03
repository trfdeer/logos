{ ... }:
{
  imports = [
    ./shell/zsh.nix
    ./shell/tmux.nix
    ./shell/direnv.nix
    ./shell/starship.nix
    ./shell/session_vars.nix

    ./dev/git.nix
    ./dev/helix.nix
    ./dev/lazygit.nix

    ./misc/nix.nix
    ./misc/utils.nix
    ./misc/catppuccin.nix

    ./desktop/sound.nix
  ];
}
