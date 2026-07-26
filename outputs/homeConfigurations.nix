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
    prefs.roles = [
      "dev"
      "desktop"
    ];
  };

  "dwai@wol" = makeHome {
    name = "wol";
    prefs = {
      isWsl = true;
      roles = [ "server" ];
    };
  };

  "dwai@zeph" = makeHome {
    name = "zeph";
    prefs.roles = [ "server" ];
  };
}
