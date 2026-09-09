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

        disabled_providers = [ "opencode" ];
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
