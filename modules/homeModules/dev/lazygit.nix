{ lib, config, ... }:
{
  options.sqwer.home.lazygit = {
    enable = lib.mkEnableOption "Enable lazygit";
  };

  config = lib.mkIf config.sqwer.home.lazygit.enable {
    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
