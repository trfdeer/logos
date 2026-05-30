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
  prefs ? { },
  extraModules ? [ ],
  extraSpecialArgs ? { },
}:
let
  prefs' = {
    isDesktop = false;
  }
  // prefs;
in
inputs.nixpkgs.lib.nixosSystem {
  system = pkgs.stdenv.hostPlatform.system;

  specialArgs = {
    inherit inputs modules profiles;

    isDesktop = prefs'.isDesktop;
    hostname = name;
  }
  // extraSpecialArgs;

  modules = [
    hosts.${name}

    modules.common
    profiles.platform

    modules.system.sqwerSystem

    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.preservation.nixosModules.preservation
    inputs.home-manager.nixosModules.home-manager

    profiles.system.base
    {
      nixpkgs = { inherit pkgs; };
    }
  ]
  ++ lib.optional prefs'.isDesktop profiles.system.desktop
  ++ extraModules;
}
