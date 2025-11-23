{ lib, config, ... }:
{
  options = {
    sqwer.zsh.enable = lib.mkEnableOption "Enable ZSH shell";
  };

  config = lib.mkIf config.sqwer.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      history.save = 0;
      loginExtra = ''
        if [[ -z $TMUX ]] && [[ -n $SSH_TTY ]]; then
          exec tmux -u new-session -A -s default
        fi
      '';
      initExtra = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
      shellAliases = {
        ls = "exa";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "tmux"
          "direnv"
        ];
      };
    };
    # // lib.optionalAttrs defs.config.isWsl {
    #   shellAliases = {
    #     ssh = "ssh.exe";
    #     ssh-add = "ssh-add.exe";
    #   };
    # };
  };
}
