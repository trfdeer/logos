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
  inherit (pkgs) lib;

  prefs' = {
    isWsl = false;
    roles = [ ];
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
      logos.platform = {
        hostName = name;
        isWsl = prefs'.isWsl;
        roles = prefs'.roles;
      };
    }
    (import ../hosts/${name}/home-configuration.nix)
  ]
  ++ lib.optional (lib.elem "dev" prefs'.roles) profiles.home.dev
  ++ lib.optional (lib.elem "desktop" prefs'.roles) profiles.home.desktop
  ++ lib.optional (lib.elem "server" prefs'.roles) profiles.home.server
  ++ extraModules;
}
