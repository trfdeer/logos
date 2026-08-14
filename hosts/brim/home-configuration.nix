{ config, pkgs, ... }:
{
  sqwer.home = {
    podman.enable = true;
  };

  home.packages = with pkgs.unstable; [
    secretspec
    rsync
    _1password-cli
  ];
}
