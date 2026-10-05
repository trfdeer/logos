{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.utils;
in
{
  options.logos.home.utils = {
    enable = lib.mkEnableOption "core shell utilities" // {
      default = true;
    };
    dev = lib.mkEnableOption "development tools";
    sensors = lib.mkEnableOption "lm_sensors hardware monitoring" // {
      default = true;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages =
        with pkgs;
        [
          jq
          eza
          zsh
          ripgrep
          _7zip-zstd
        ]
        ++ [ pkgs.just ]
        ++ lib.optional cfg.sensors lm_sensors;

      programs.btop = {
        enable = true;
        settings = {
          theme_background = false;
        };
      };

      programs.zoxide = {
        enable = true;
      }
      // (lib.optionalAttrs config.logos.home.zsh.enable {
        enableZshIntegration = true;
      });

      home.shellAliases.cd = "z";
    })

    (lib.mkIf (cfg.enable && cfg.dev) {
      home.packages =
        with pkgs;
        [
          gh
          helix
        ]
        ++ (with pkgs.unstable; [
          secretspec
        ]);
    })
  ];
}
