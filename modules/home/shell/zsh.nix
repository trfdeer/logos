{ lib, config, ... }:
let
  homeCfg = config.logos.home;
in
{
  options.logos.home.zsh = {
    enable = lib.mkEnableOption "Enable ZSH" // {
      default = true;
    };
  };

  config = lib.mkIf config.logos.home.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      history.save = 0;
      initContent = ''
        nr() {
          nix run "nixpkgs#$1" -- "''${@:2}"
        }

        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      ''
      + lib.optionalString homeCfg.tmux.enable ''

        # Decide whether tmux auto-start should be skipped
        SKIP_TMUX=0

        if [[ $(tty) == /dev/tty[0-9]* ]]; then
          SKIP_TMUX=1
        elif [[ "$TERM_PROGRAM" == "vscode" ]] || [[ -n "$VSCODE_PID" ]]; then
          SKIP_TMUX=1
        elif [[ -n "$SSH_ORIGINAL_COMMAND" ]]; then
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

      shellAliases =
        lib.optionalAttrs homeCfg.utils.enable {
          ls = "eza";
        }
        // lib.optionalAttrs homeCfg.k8s.enable {
          k = "kubectl --cache-dir=$XDG_CACHE_HOME/kubectl";
          kd = "kubectl --cache-dir=$XDG_CACHE_HOME/kubectl describe";
          kubectl = "kubectl --cache-dir=$XDG_CACHE_HOME/kubectl";
        }
        // lib.optionalAttrs (homeCfg._1password.enable && config.logos.platform.isWsl) {
          # Use the Windows 1Password CLI via WSL interop; there is no Linux `op` on WSL hosts.
          op = "op.exe";
        };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "sudo"
        ]
        ++ lib.optionals homeCfg.tmux.enable [ "tmux" ]
        ++ lib.optionals homeCfg.git.enable [ "git" ]
        ++ lib.optionals homeCfg.direnv.enable [ "direnv" ];
      };
    };
  };
}
