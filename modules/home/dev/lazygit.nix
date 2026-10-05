{ lib, config, ... }:
{
  options.logos.home.lazygit = {
    enable = lib.mkEnableOption "Enable lazygit";
  };

  config = lib.mkIf config.logos.home.lazygit.enable {
    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
