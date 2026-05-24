{
  pkgs,
  inputs,
  modules,
  profiles,
  utils,
  ...
}:
let
  makeHome = import utils.makeHome {
    inherit
      pkgs
      modules
      profiles
      inputs
      ;
  };
in
{
  primary = makeHome {
    extraModules = [
      profiles.home.desktop
    ];
  };
}
