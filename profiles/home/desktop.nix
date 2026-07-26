{ lib, ... }:
{
  sqwer = {
    home = {
      ssh.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;

      sound = {
        disable-hsp = lib.mkDefault false;
        disable-hw-volume = lib.mkDefault false;
      };

      _1password.enable = lib.mkDefault true;
    };
  };
}
