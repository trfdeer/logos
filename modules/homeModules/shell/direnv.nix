{ lib, config, ... }:
{
  options.sqwer.home.direnv = {
    enable = lib.mkEnableOption "Enable direnv";
  };

  config = lib.mkIf config.sqwer.home.direnv.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = config.sqwer.home.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
