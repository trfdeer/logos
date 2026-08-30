{ config, pkgs, ... }:
{
  home.packages =
    with pkgs.unstable;
    [
      yubikey-manager
      nix-tree
      bws
    ]
    ++ (with pkgs; [
      wor.wor-kvm
    ]);

  sqwer.home = {
    opencode.enable = true;
    _1password.enable = true;

    sound = {
      disable-hw-volume = true;
    };
  };
}
