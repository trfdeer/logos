{
  pkgs,
  modules,
  profiles,
  inputs,
}:
{
  extraModules ? [ ],
}:

inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    modules.commonModules
    modules.homeModules.standalone.nix
    profiles.identities.primary
    profiles.platform

    modules.homeModules.sqwerHome
    profiles.home.base
  ]
  ++ extraModules;
}
