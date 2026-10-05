{ lib, config, ... }:
{
  options.logos.home.direnv = {
    enable = lib.mkEnableOption "Enable direnv";
  };

  config = lib.mkIf config.logos.home.direnv.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = config.logos.home.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
