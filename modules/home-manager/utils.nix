{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    sqwer.utils.enable = lib.mkEnableOption "Install common tools";
  };

  config = lib.mkIf config.sqwer.utils.enable {
    home.packages = with pkgs; [
      zsh
      tmux
      git
      devenv

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

      nixd
      nixfmt-rfc-style

      #uv
      #bun
    ];

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
