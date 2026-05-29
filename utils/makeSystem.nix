{
  lib,
  pkgs,
  inputs,
  modules,
  profiles,
  hosts,
}:
{
  name,
  isDesktop ? false,
  isAmnesic ? false,
  extraModules ? [ ],
  extraSpecialArgs ? { },
}:

inputs.nixpkgs.lib.nixosSystem {
  system = pkgs.stdenv.hostPlatform.system;

  specialArgs = {
    inherit
      inputs
      modules
      profiles
      isDesktop
      ;
    hostname = name;
  }
  // extraSpecialArgs;

  modules = [
    hosts.${name}

    modules.common
    profiles.platform

    modules.system.sqwerSystem

    inputs.home-manager.nixosModules.home-manager

    profiles.system.base
    {
      nixpkgs = { inherit pkgs; };
    }
  ]
  ++ lib.optionals isAmnesic [
    inputs.preservation.nixosModules.preservation
  ]
  ++ lib.optionals isDesktop [
    profiles.system.desktop
  ]
  ++ extraModules;
}
