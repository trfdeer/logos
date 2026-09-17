{ lib, config, ... }:
{
  sqwer = {
    home = {
      ssh.enable = lib.mkDefault true;
      fonts.enable = config.sqwer.platform.isNixosSystem;

      sound = {
        disable-hsp = lib.mkDefault false;
        disable-hw-volume = lib.mkDefault false;
      };

      _1password.enable = lib.mkDefault true;
    };
  };
}
