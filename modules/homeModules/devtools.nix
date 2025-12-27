{ lib, config, ... }:
let
  cfg = config.sqwer.devtools;
in
{
  options.sqwer.devtools = {
    basePath = lib.mkOption {
      type = lib.types.path;
      description = "Base code path";
    };

    go.enable = lib.mkEnableOption "Install go compiler";
    rust.enable = lib.mkEnableOption "Enable rust toolchain";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.go.enable {
      programs.go = {
        enable = true;
        telemetry.mode = "off";
        env.GOPATH = "${cfg.basePath}/go";
      };
    })
    (lib.mkIf cfg.rust.enable {
      home.sessionVariables = {
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
      };
    })
  ];
}
