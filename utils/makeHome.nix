{
  pkgs,
  modules,
  profiles,
  inputs,
}:
{
  name,
  extraModules ? [ ],
}:

inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    modules.common
    profiles.platform

    modules.home
    profiles.home.base
    {
      nix.package = pkgs.nix;
      sqwer.platform.hostName = name;
    }
  ]
  ++ extraModules;
}
