{ lib, config, ... }:

let
  cfg = config.sqwer.catppuccin;

  mkCatppuccin =
    enableCond: extra:
    lib.mkIf enableCond (
      {
        enable = true;
        flavor = cfg.flavor;
      }
      // extra
    );

in
{
  options.sqwer.catppuccin = {
    enable = lib.mkEnableOption "Enable Catppuccin Theme";
    flavor = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Catppuccin Theme Variant";
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      zsh-syntax-highlighting = mkCatppuccin config.sqwer.zsh.enable { };
      btop = mkCatppuccin config.sqwer.utils.enable { };
      tmux = mkCatppuccin config.sqwer.tmux.enable { };
      starship = mkCatppuccin config.sqwer.starship.enable { };
      lazygit = mkCatppuccin config.sqwer.lazygit.enable { };
      helix = mkCatppuccin config.sqwer.helix.enable { useItalics = true; };
    };
  };
}
