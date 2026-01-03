{ ... }:
{
  imports = [
    ./network/tailscale.nix
    ./network/samba.nix

    ./hardware/hyper-v.nix
  ];
}
