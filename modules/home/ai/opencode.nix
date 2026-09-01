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
          hyper.whitelist = [
            "glm-5.3"
            "deepseek-v4-flash-0731"
            "glm-5.3-flash"
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
