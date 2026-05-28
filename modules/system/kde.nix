{ lib, config, ... }:
let
  cfg = config.sqwer.system.kde;
in
{
  options.sqwer.system.kde = {
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
