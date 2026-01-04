{ ... }:
{
  imports = [
    ./docker.nix

    ./network/tailscale.nix
    ./network/samba.nix

    ./hardware/hyper-v.nix
  ];
}
