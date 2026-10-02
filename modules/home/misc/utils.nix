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
          zsh
          ripgrep
          neovim
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

      programs.zoxide = {
        enable = true;
      }
      // (lib.optionalAttrs config.sqwer.home.zsh.enable {
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
