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

        # Decide whether tmux auto-start should be skipped
        SKIP_TMUX=0

        if [[ "$TERM_PROGRAM" == "vscode" ]] || [[ -n "$VSCODE_PID" ]]; then
          SKIP_TMUX=1
        fi

        if [[ -n "$SSH_ORIGINAL_COMMAND" ]]; then
          SKIP_TMUX=1
        fi

        case "$TERM" in
          dumb) SKIP_TMUX=1 ;;
        esac

        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -t 0 ]] && [[ "$SKIP_TMUX" -eq 0 ]]; then
          SESSION="main"

          if tmux has-session -t "$SESSION" 2>/dev/null; then
            exec tmux attach-session -t "$SESSION"
          else
            exec tmux new-session -s "$SESSION"
          fi
        fi
      '';
      shellAliases = lib.mkMerge [
        (lib.mkIf config.sqwer.utils.enable { ls = "exa"; })
        (lib.mkIf config.sqwer.git._1password.isWsl {
          ssh = "ssh.exe";
          ssh-add = "ssh-add.exe";
        })
      ];
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

    catppuccin.zsh-syntax-highlighting = {
      enable = true;
      flavor = "mocha";
    };
  };
}
