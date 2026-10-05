{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.hax;

  settingsFormat = pkgs.formats.json { };

  # Typed conveniences merged into the freeform `settings`; explicit
  # `settings` values win.
  baseSettings = lib.filterAttrs (_: v: v != null) {
    inherit (cfg) provider model effort;
  };

  presets = lib.optionalAttrs (cfg.presets != { }) {
    presets = cfg.presets;
  };

  mergedSettings = baseSettings // presets // cfg.settings;
in
{
  options.logos.home.hax = {
    enable = lib.mkEnableOption "hax";
    package = lib.mkPackageOption pkgs.llm-agents "hax" { nullable = false; };

    provider = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "openai-compatible";
      description = "Default provider id (`config.json` `provider`).";
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Qwen3-30B";
      description = "Default model id (`config.json` `model`).";
    };

    effort = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "high";
      description = "Provider-specific reasoning effort (`config.json` `effort`).";
    };

    presets = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          daily = {
            description = "favorite everyday model";
            provider = "openrouter";
            model = "deepseek/deepseek-v4-flash-0731";
            tint = "teal";
          };
          review = {
            description = "thorough code review";
            provider = "codex";
            model = "gpt-5.6-sol";
            effort = "high";
            system_prompt_append = "@prompts/review.md";
            tint = "rose";
          };
        }
      '';
      description = ''
        Presets written under `config.json` `presets`. Only presets with a
        `description` are advertised to the model for subagent delegation.

        `system_prompt` and `system_prompt_append` accept `@path`; relative
        paths resolve from the hax config directory.
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          providers.openai-compatible = {
            display_name = "vLLM";
            base_url = "http://127.0.0.1:8000/v1";
          };
          theme = "dark";
          compact.threshold = 80;
        }
      '';
      description = ''
        Freeform `config.json` content, written to
        {file}`$XDG_CONFIG_HOME/hax/config.json` as a read-only store symlink
        (updated on every switch).

        See <https://github.com/OleksandrChekhovskyi/hax/blob/master/docs/configuration.md>.

        Keep secrets in environment variables (`OPENAI_API_KEY`, ...) or
        `api_key_env`; never inline credentials here.
      '';
    };

    secretEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        HYPER_API_KEY = "op://Private/hyper/credential";
      };
      description = ''
        Secret environment variables for hax, as `op://` references. Rendered
        to {file}`$XDG_CONFIG_HOME/hax/env` (references only, no secrets on
        disk) and applied through a `hax` shell alias pointing at a
        `hax-secrets` wrapper.

        The wrapper resolves each reference with `op read` at launch — using
        the Linux `op` CLI when available, falling back to `op.exe` on WSL —
        and execs the real hax with the variables set, so the secrets exist
        only inside the hax process. Resolved values are cached for the
        login session in `$XDG_RUNTIME_DIR` (per-user tmpfs, 0600, wiped on
        logout/reboot), so 1Password is contacted once per login. Requires
        `op` (or `op.exe`) on PATH with 1Password CLI integration.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];

        # Managed as a read-only store symlink (like opencode.json). Note the
        # trade-off: hax commands that rewrite `config.json` — notably
        # `/preset-save` — will fail against the read-only store; change
        # presets in Nix instead. (`/config` runtime overrides are unaffected;
        # they persist in state.json, not config.json.)
        xdg.configFile."hax/config.json" = lib.mkIf (mergedSettings != { }) {
          source = settingsFormat.generate "hax-config.json" mergedSettings;
        };
      }

      (lib.mkIf (cfg.secretEnv != { }) {
        # `op://` references only; resolved by the wrapper at launch.
        xdg.configFile."hax/env".text =
          lib.concatStringsSep "\n" (lib.mapAttrsToList (name: ref: "${name}=${ref}") cfg.secretEnv) + "\n";

        home.packages = [
          # `op run --env-file` cannot be used on WSL: op.exe is a Windows
          # binary and cannot exec the Linux hax as its child. Instead,
          # resolve each reference from WSL via `op read` (works with both a
          # native `op` and `op.exe`) and exec hax with the results.
          #
          # Resolved values are cached for the login session in
          # $XDG_RUNTIME_DIR (per-user tmpfs, 0600, wiped on logout/reboot),
          # so the 1Password round-trip happens once per login instead of on
          # every launch. Secrets rotated in 1Password are picked up at the
          # next login.
          (pkgs.writeShellScriptBin "hax-secrets" ''
            set -euo pipefail

            runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
            cache="$runtime_dir/hax/secrets.env"

            envfile="${config.xdg.configHome}/hax/env"
            need_resolve=1

            if [[ -s "$cache" ]]; then
              # Values are written quoted (printf %q), so sourcing is safe.
              # shellcheck disable=SC1090
              source "$cache"
              # Treat the cache as a miss if any configured variable is
              # missing from it (e.g. secretEnv changed mid-session).
              need_resolve=0
              while IFS= read -r line || [[ -n "$line" ]]; do
                [[ -z "$line" || "$line" == \#* ]] && continue
                if ! declare -p "''${line%%=*}" >/dev/null 2>&1; then
                  need_resolve=1
                  break
                fi
              done < "$envfile"
            fi

            if [[ "$need_resolve" == 1 ]]; then
              op_bin="$(command -v op || true)"
              if [[ -z "''${op_bin}" ]]; then
                op_bin="$(command -v op.exe || true)"
              fi
              if [[ -z "''${op_bin}" ]]; then
                echo "hax-secrets: no 'op' or 'op.exe' on PATH" >&2
                exit 1
              fi

              resolved=()
              while IFS= read -r line || [[ -n "$line" ]]; do
                [[ -z "$line" || "$line" == \#* ]] && continue
                key="''${line%%=*}"
                ref="''${line#*=}"
                value="$("$op_bin" read "$ref" | tr -d '\r')"
                resolved+=("''${key}=$(printf '%q' "$value")")
                export "$key=$value"
              done < "$envfile"

              umask 077
              mkdir -p "$runtime_dir/hax"
              printf 'export %s\n' "''${resolved[@]}" > "$cache"
            fi

            exec ${lib.getExe cfg.package} "$@"
          '')
        ];

        home.shellAliases.hax = "hax-secrets";
      })
    ]
  );
}
