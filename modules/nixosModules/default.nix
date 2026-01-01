{ lib, ... }:
{
  imports = [
    ./tailscale.nix
    ./samba.nix

    ./hardware/hyper-v.nix
  ];

  config.sqwer = {
    tailscale = {
      enable = lib.mkDefault false;
      operator = lib.mkDefault "";
      advertiseRoutes = lib.mkDefault "";
    };

    samba = {
      enable = lib.mkDefault false;
      name = lib.mkDefault "";
      path = lib.mkDefault "";
      owner = lib.mkDefault "";
    };

    hardware.hyperv = {
      enable = false;
    };
  };
}
