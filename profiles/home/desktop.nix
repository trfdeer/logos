{ lib, ... }:
{
  sqwer = {
    platform.isDesktop = true;

    home.sound = {
      disable-hsp = lib.mkDefault true;
      disable-hw-volume = lib.mkDefault true;
    };

    home.fonts.enable = true;
  };
}
