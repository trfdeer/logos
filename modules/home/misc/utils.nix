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
    home.packages = with pkgs; [
      zsh
      tmux
      git
      devenv
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

      lm_sensors
    ];

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
