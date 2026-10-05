{ config, pkgs, ... }:
{
  sqwer.home = {
    helix.enable = true;
  };

  home.packages = with pkgs.unstable; [
    secretspec
    rsync
    _1password-cli
  ];
}
