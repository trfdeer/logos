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
    isAmnesic = true;
    provisionDisks = true;
    useSecureBoot = true;
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

    inputs.home-manager.nixosModules.home-manager

    profiles.system.base
    {
      nixpkgs = { inherit pkgs; };
    }
  ]
  ++ lib.optional prefs'.isAmnesic inputs.preservation.nixosModules.preservation
  ++ lib.optional prefs'.useSecureBoot inputs.lanzaboote.nixosModules.lanzaboote
  ++ lib.optional prefs'.provisionDisks inputs.disko.nixosModules.disko
  ++ lib.optional prefs'.isDesktop profiles.system.desktop
  ++ extraModules;
}
