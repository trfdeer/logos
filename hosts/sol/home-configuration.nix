{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yubikey-manager
    nix-tree
    opentofu
  ];

  sqwer.home.k8s.enable = true;

  home.sessionPath = [
    "$HOME/.opencode/bin"
  ];
}
