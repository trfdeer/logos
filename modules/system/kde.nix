{ lib, config, ... }:
let
  cfg = config.logos.system.kde;
in
{
  options.logos.system.kde = {
    enable = lib.mkEnableOption "KDE Plasma";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.General.DisplayServer = "wayland";
    };

  };
}
