{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yubikey-manager
    nix-tree
  ];
}
