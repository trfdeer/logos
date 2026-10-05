{ lib, config, ... }:
{
  logos = {
    home = {
      ssh.enable = lib.mkDefault true;
      fonts.enable = config.logos.platform.isNixosSystem;

      sound = {
        disable-hsp = lib.mkDefault false;
        disable-hw-volume = lib.mkDefault false;
      };

      _1password.enable = lib.mkDefault true;
    };
  };
}
