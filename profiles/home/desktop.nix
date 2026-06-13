{ lib, ... }:
{
  sqwer = {
    platform.isDesktop = true;

    home = {
      sound = {
        disable-hsp = lib.mkDefault true;
        disable-hw-volume = lib.mkDefault true;
      };
      _1password.enable = true;
      fonts.enable = true;
    };
  };
}
