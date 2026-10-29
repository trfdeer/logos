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
  brim = makeSystem {
    name = "brim";
    prefs.roles = [ "server" ];
  };
  sol = makeSystem {
    name = "sol";
    prefs.roles = [
      "desktop"
      "dev"
    ];
  };
  zeph = makeSystem {
    name = "zeph";
    prefs.roles = [ "server" ];
  };
  syf = makeSystem {
    name = "syf";
    prefs = {
      isWsl = true;
      roles = [ "dev" ];
    };
  };

  # Proxmox LXC Container
  rift = makeSystem {
    name = "rift";
    prefs.isLxc = true;
  };

  # VPS
  star = makeSystem {
    name = "star";
    prefs.roles = [ "server" ];
  };
}
