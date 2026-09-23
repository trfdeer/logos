{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.opencode;
in
{
  options.sqwer.home.opencode = {
    enable = lib.mkEnableOption "OpenCode";
    package = lib.mkPackageOption pkgs "opencode" { nullable = false; };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = cfg.package;
      extraPackages = with pkgs; [
        bun
      ];

      settings = {
        formatter = true;
        share = "disabled";
        update = "disable";

        permissions = [
          # Default posture: anything not explicitly allowed below needs
          # approval. This must come FIRST — rules combine in order and
          # the last match wins, so later rules refine it.
          {
            action = "*";
            resource = "*";
            effect = "ask";
          }

          # Read-only file access within the current directory.
          {
            action = "read";
            resource = "*";
            effect = "allow";
          }
          {
            action = "read";
            resource = "*.env.example";
            effect = "allow";
          }

          # Read-only git commands are always allowed. Simple subcommands
          # are safe with any arguments; listing-only flags are matched
          # explicitly so mutating flags (-d, -D, --delete) fall through
          # to the ask-all rule above.
        ]
        ++
          map
            (cmd: {
              action = "shell";
              resource = "git ${cmd} *";
              effect = "allow";
            })
            [
              "status"
              "log"
              "diff"
              "show"
              "blame"
              "rev-parse"
              "describe"
              "ls-files"
              "shortlog"
            ]
        ++
          map
            (args: {
              action = "shell";
              resource = "git ${args} *";
              effect = "allow";
            })
            [
              "tag -l"
              "tag --list"
              "branch -l"
              "branch --list"
              "branch -a"
              "branch --all"
              "branch -r"
              "branch --remotes"
              "branch -v"
              "remote -v"
              "remote --verbose"
              "reflog show"
            ]
        ++ [
          # Hard denies, kept last so nothing above can re-allow them.
          # Never touch .runtime state (decrypted secrets, caches) at the
          # workspace root or in any subfolder.
          {
            action = "*";
            resource = "*.runtime/*";
            effect = "deny";
          }
          {
            action = "shell";
            resource = "*.runtime*";
            effect = "deny";
          }
          {
            action = "read";
            resource = "*.env";
            effect = "deny";
          }
          {
            action = "read";
            resource = "*.env.*";
            effect = "deny";
          }
        ];

        model = "hyper/glm5.3-flash";
        agents.title.model = "hyper/glm5.3-flash";

        mcp.servers = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };

          plane = {
            type = "remote";
            url = "https://mcp.plane.so/http/mcp";
          };

          nixos = {
            type = "local";
            command = [
              "nix"
              "run"
              "github:utensils/mcp-nixos/v3.1.0"
              "--"
            ];
          };

          firefox-devtools = {
            type = "local";
            command = [
              "bun"
              "x"
              "@mozilla/firefox-devtools-mcp@latest"
              "--viewport"
              "1920x1080"
              "--profile-path"
              "./.runtime/mcp/firefox-devtools/profile"
            ];
            env = {
              START_URL = "about:blank";
            };
          };
        };

        experimental.policies = [
          {
            action = "provider.use";
            resource = "opencode";
            effect = "deny";
          }
        ];
      };

      agents = {
        monday = ./agents/monday.md;
      };

      skills = {
        commit-conventions = ./skills/commit-conventions;
      };

      tui = {
        theme = "aura";
        diff_style = "auto";

        attention = {
          enabled = true;
          notifications = true;
          sound = false;
        };
      };

      web = {
        enable = true;
      };
    };

    home.shellAliases.oc = "opencode";
  };
}
