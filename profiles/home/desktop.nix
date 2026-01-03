{ lib, ... }:
{
  sqwer = {
    env = {
      has1Password = true;
      isDesktop = true;
    };

    home.sound = {
      disable-hsp = lib.mkDefault true;
      disable-hw-volume = lib.mkDefault true;
    };
  };
}
