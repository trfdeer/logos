{
  lib,
  nixpkgs,
  inputs,
  modules,
  profiles,
  system,
  hosts,
}:
{
  name,
  isDesktop ? false,
  extraModules ? [ ],
  extraSpecialArgs ? { },
}:

nixpkgs.lib.nixosSystem {
  inherit system;

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

    modules.commonModules
    profiles.identities.primary
    profiles.platform

    modules.nixosModules.sqwerSystem

    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager

    profiles.system.base
  ] ++ lib.optionals (isDesktop) [
    profiles.system.desktop
  ]
  ++ extraModules;
}
