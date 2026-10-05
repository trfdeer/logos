{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.fonts;
in
{
  options.logos.home.fonts = {
    enable = lib.mkEnableOption "Install Fonts";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      iosevka
      nerd-fonts.iosevka-term
    ];
  };
}
