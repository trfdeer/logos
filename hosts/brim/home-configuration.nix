{ config, pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    secretspec
    rsync
    _1password-cli
  ];
}
