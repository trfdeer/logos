{
  nixpkgs,
  inputs,
  modules,
  profiles,
  system,
  hosts,
}:
{
  name,
  extraModules ? [ ],
  extraSpecialArgs ? { },
}:

nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs modules profiles;
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
  ]
  ++ extraModules;
}
