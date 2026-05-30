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

  # Proxmox LXC Container
  rift = makeSystem {
    name = "rift";
    extraModules = [ modules.system.standalone.hardware.proxmox-lxc ];
  };
}
