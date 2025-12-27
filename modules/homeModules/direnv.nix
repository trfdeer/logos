{ lib, config, ... }:
{
  options.sqwer.direnv = {
    enable = lib.mkEnableOption "Enable direnv";
  };

  config = lib.mkIf config.sqwer.direnv.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = config.sqwer.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
