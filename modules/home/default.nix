{
  imports = [
    ./shell/ssh.nix
    ./shell/zsh.nix
    ./shell/gpg.nix
    ./shell/tmux.nix
    ./shell/direnv.nix
    ./shell/starship.nix
    ./shell/session_vars.nix

    ./ai/opencode.nix
    ./ai/opencode2.nix
    ./ai/hax.nix
    ./ai/mcp.nix

    ./dev/k8s.nix
    ./dev/git.nix
    ./dev/helix.nix
    ./dev/neovim.nix
    ./dev/lazygit.nix
    ./dev/podman.nix

    ./misc/nix.nix
    ./misc/utils.nix
    ./misc/_1password.nix

    ./desktop/sound.nix
    ./desktop/fonts.nix
  ];
}
