{ lib, config, ... }:
let
  cfg = config.sqwer.home.gpg;
in
{
  options.sqwer.home.gpg = {
    enable = lib.mkEnableOption "Enable GPG";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
