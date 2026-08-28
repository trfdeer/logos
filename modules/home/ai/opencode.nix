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
    package = lib.mkPackageOption pkgs.unstable "opencode" { nullable = false; };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = cfg.package;

      settings = {
        lsp = true;
        formatter = true;
        share = "disabled";
        autoupdate = false;

        permission = {
          external_directory = "ask";
        };

        disabled_providers = [ "opencode" ];
        provider = {
          openai.whitelist = [
            "gpt-5.6-luna"
            "gpt-5.6-sol"
            "gpt-5.6-terra"
          ];

          hyper.whitelist = [
            "deepseek-v4-flash"
            "kimi-k2.7-code"
            "minimax-m3"
            "qwen3.8-flash"
          ];

          hetzner.whitelist = [
            "Qwen3.8-27B"
          ];
        };
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
