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
      dotDir = "${config.xdg.configHome}/zsh";
      history.save = 0;
      initContent = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      ''
      + lib.optionalString config.sqwer.tmux.enable ''

        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -t 0 ]]; then
          # Skip if running in VS Code terminal
          if [[ "$TERM_PROGRAM" == "vscode" ]] || [[ -n "$VSCODE_PID" ]]; then
              return
          fi

          # Skip if ssh was invoked with a remote command (non-tty)
          if [[ -n "$SSH_ORIGINAL_COMMAND" ]]; then
              return
          fi

          # Skip for "dumb" terminals or automation tools
          case "$TERM" in
              dumb) return ;;
          esac

          # Default tmux session name
          SESSION="main"

          # Check if session exists, attach or create accordingly
          if tmux has-session -t "$SESSION" 2>/dev/null; then
              exec tmux attach-session -t "$SESSION"
          else
              exec tmux new-session -s "$SESSION"
          fi
        fi
      '';
      shellAliases = { } // lib.optionalAttrs config.sqwer.utils.enable { ls = "exa"; };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "sudo"
        ]
        ++ lib.optionals config.sqwer.tmux.enable [ "tmux" ]
        ++ lib.optionals config.sqwer.git.enable [ "git" ]
        ++ lib.optionals config.sqwer.direnv.enable [ "direnv" ];

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
