{
  pkgs,
  inputs,
  modules,
  profiles,
  hosts,
  utils,
  ...
}:
let
  makeSystem = import utils.makeSystem {
    lib = pkgs.lib;
    inherit
      inputs
      pkgs
      modules
      profiles
      hosts
      ;
  };
in
{
  # Installer & Test VM
  seed = makeSystem { name = "seed"; };
  beet = makeSystem { name = "beet"; };

  # Devices
  brim = makeSystem { name = "brim"; };
  sol = makeSystem { name = "sol"; };
  zeph = makeSystem { name = "zeph"; };
  wol = makeSystem {
    name = "wol";
    prefs.isWsl = true;
  };

  # Proxmox LXC Container
  rift = makeSystem {
    name = "rift";
    prefs.isLxc = true;
  };
}
