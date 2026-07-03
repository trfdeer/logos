{ pkgs, ... }:
{
  sqwer.home = {
    k8s.enable = true;
  };

  home.packages = with pkgs; [ yubikey-manager ];
}
