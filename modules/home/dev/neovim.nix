{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.logos.home.neovim = {
    enable = lib.mkEnableOption "Enable Neovim Editor" // {
      default = true;
    };
  };

  config = lib.mkIf config.logos.home.neovim.enable {
    home.packages = with pkgs; [ neovim ];
  };
}
