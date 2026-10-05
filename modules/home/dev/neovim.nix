{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.sqwer.home.neovim = {
    enable = lib.mkEnableOption "Enable Neovim Editor" // {
      default = true;
    };
  };

  config = lib.mkIf config.sqwer.home.neovim.enable {
    home.packages = with pkgs; [ neovim ];
  };
}
