{
  pkgs,
  modules,
  profiles,
  inputs,
}:
{
  name,
  prefs ? { },
  extraModules ? [ ],
}:
let
  prefs' = {
    isWsl = false;
  }
  // prefs;
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    modules.common
    profiles.platform

    modules.home
    profiles.home.base
    {
      nix.package = pkgs.nix;
      sqwer.platform = {
        hostName = name;
        isWsl = prefs'.isWsl;
      };

    }
  ]
  ++ extraModules;
}
