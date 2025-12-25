{ lib, config, ... }:
{
  options = {
    sqwer.lazygit.enable = lib.mkEnableOption "Enable lazygit";
  };

  config = lib.mkIf config.sqwer.lazygit.enable {
    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
    };

    catppuccin.lazygit = {
      enable = true;
      flavor = "mocha";
    };
  };
}
