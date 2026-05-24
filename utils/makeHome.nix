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
    profiles.platform

    modules.homeModules
    profiles.home.base
    {
      nix.package = pkgs.nix;
    }
  ]
  ++ extraModules;
}
