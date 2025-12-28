{ lib, ... }:
{
  imports = [
    ./identity.nix
    ./platform.nix
  ];

  config.sqwer = {
    identity = lib.mkDefault { };
    platform = lib.mkDefault { };
  };
}
