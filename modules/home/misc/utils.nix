{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.sqwer.home.utils = {
    enable = lib.mkEnableOption "Install common tools";
  };

  config = lib.mkIf config.sqwer.home.utils.enable {
    home.packages =
      with pkgs;
      [
        nh
        zsh
        tmux
        git
        just

        coreutils
        aria2
        curl
        wget
        file

        eza
        bat
        ripgrep
        fzf
        nnn
        btop
        fd
        jq

        lm_sensors
      ]
      ++ (with pkgs.unstable; [
        devenv
      ]);

    programs.btop.enable = true;

    programs.topgrade = {
      enable = true;
      settings = {
        misc = {
          cleanup = true;
        };
      };
    };
  };
}
