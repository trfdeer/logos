{ lib, ... }:
{
  imports = [
    ./identity.nix
    ./platform.nix
    ./env.nix
  ];

  sqwer.env = {
    isWsl = lib.mkDefault false;
    has1Password = lib.mkDefault false;
  };
}
