{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.utils;
in
{
  options.sqwer.home.utils = {
    enable = lib.mkEnableOption "core shell utilities" // {
      default = true;
    };
    dev = lib.mkEnableOption "development tools";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages =
        with pkgs;
        [
          jq
          nh
          eza
          vim
          zsh
          ripgrep
          _7zip-zstd
          lm_sensors
        ]
        ++ (with pkgs.unstable; [ just ]);

      programs.btop = {
        enable = true;
        settings = {
          theme_background = false;
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.dev) {
      home.packages =
        with pkgs;
        [
          git
          helix
          go-task
        ]
        ++ (with pkgs.unstable; [
          secretspec
        ]);
    })
  ];
}
