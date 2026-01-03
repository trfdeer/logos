{ lib, config, ... }:
let
  homeCfg = config.sqwer.home;

  mkCatppuccin =
    enableCond: extra:
    lib.mkIf enableCond (
      {
        enable = true;
        flavor = homeCfg.catppuccin.flavor;
      }
      // extra
    );

in
{
  options.sqwer.home.catppuccin = {
    enable = lib.mkEnableOption "Enable Catppuccin Theme";
    flavor = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "";
      description = "Catppuccin Theme Variant";
    };
  };

  config = lib.mkIf homeCfg.catppuccin.enable {
    catppuccin = {
      zsh-syntax-highlighting = mkCatppuccin homeCfg.zsh.enable { };
      btop = mkCatppuccin homeCfg.utils.enable { };
      tmux = mkCatppuccin homeCfg.tmux.enable { };
      starship = mkCatppuccin homeCfg.starship.enable { };
      lazygit = mkCatppuccin homeCfg.lazygit.enable { };
      helix = mkCatppuccin homeCfg.helix.enable { useItalics = true; };
    };
  };
}
