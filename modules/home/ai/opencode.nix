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
        lsp = true;
        formatter = true;
        share = "disabled";
        autoupdate = false;

        permission = {
          external_directory = "ask";
        };

        model = "hyper/qwen3.8-flash";
        small_model = "hyper/qwen3.8-flash";

        mcp = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };

          grep = {
            type = "remote";
            url = "https://mcp.grep.app";
          };

          plane = {
            type = "remote";
            url = "https://mcp.plane.so/http/mcp";
          };

          firefox-devtools = {
            enabled = true;
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

        disabled_providers = [ "opencode" ];
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

    home.shellAliases.oc = "opencode2";
  };
}
