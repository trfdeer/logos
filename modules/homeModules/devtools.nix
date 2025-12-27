{ lib, config, ... }:
{
  options = {
    sqwer.devtools.basePath = lib.mkOption {
      type = lib.types.path;
      description = "Base code path";
    };
    sqwer.devtools.go.enable = lib.mkEnableOption "Install go compiler";
  };

  config = lib.mkMerge [
    (lib.mkIf config.sqwer.devtools.go.enable {
      programs.go = {
        enable = true;
        telemetry.mode = "off";
        env.GOPATH = "${config.sqwer.devtools.basePath}/go";
      };
    })
  ];
}
