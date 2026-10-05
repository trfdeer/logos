{ lib, config, ... }:
let
  cfg = config.logos.home.gpg;
in
{
  options.logos.home.gpg = {
    enable = lib.mkEnableOption "Enable GPG";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
