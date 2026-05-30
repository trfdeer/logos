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
  inherit (inputs) disko lanzaboote;

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

  makeVirtualSystem =
    args:
    makeSystem (
      args
      // {
        prefs = {
          provisionDisks = false;
          useSecureBoot = false;
          isAmnesic = false;
        }
        // (args.prefs or { });
      }
    );

in
{
  # Installer & Test VM
  seed = makeVirtualSystem { name = "seed"; };
  beet = makeSystem { name = "beet"; };

  # Devices
  brim = makeSystem { name = "brim"; };
  sol = makeSystem { name = "sol"; };
  zeph = makeSystem {
    name = "zeph";
    prefs.isDesktop = true;
  };

  # Proxmox LXC Container
  rift = makeVirtualSystem {
    name = "rift";
    extraModules = [ modules.system.standalone.hardware.proxmox-lxc ];
  };
}
