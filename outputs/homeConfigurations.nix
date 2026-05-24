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
  "dwai@sol" = makeHome {
    name = "sol";
    extraModules = [
      profiles.home.desktop
    ];
  };
}
