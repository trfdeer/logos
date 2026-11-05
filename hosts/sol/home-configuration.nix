{ config, pkgs, ... }:
{
  home.packages =
    with pkgs.unstable;
    [
      yubikey-manager
      nix-tree

      mitmproxy
    ]
    ++ (with pkgs; [
      wor.wor-kvm
    ]);

  logos.home = {
    opencode.enable = true;
    _1password.enable = true;
    k8s.enable = true;

    sound = {
      disable-hw-volume = true;
    };
  };
}
