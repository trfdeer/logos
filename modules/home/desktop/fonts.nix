{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.fonts;
in
{
  options.sqwer.home.fonts = {
    enable = lib.mkEnableOption "Install Fonts";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      iosevka
    ];
  };
}
