{ config, pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    yubikey-manager
    nix-tree
    bws
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
  ];

  sqwer.home = {
    sound = {
      disable-hw-volume = true;
    };
  };
}
