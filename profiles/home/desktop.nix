{ lib, ... }:
{
  sqwer = {
    platform.isDesktop = true;

    home = {
      sound = {
        disable-hsp = lib.mkDefault false;
        disable-hw-volume = lib.mkDefault false;
      };
      _1password.enable = true;
      fonts.enable = true;
    };
  };
}
