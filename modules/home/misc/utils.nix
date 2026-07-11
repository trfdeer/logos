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
        zsh
        tmux
        git
        just

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

        _7zz
        lm_sensors
      ]
      ++ (with pkgs.unstable; [
        nh
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
