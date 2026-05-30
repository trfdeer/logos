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
in
{
  seed = makeSystem {
    name = "seed";
  };

  brim = makeSystem {
    name = "brim";
    isAmnesic = true;
    extraModules = [
      disko.nixosModules.disko
      lanzaboote.nixosModules.lanzaboote
    ];
  };

  sol = makeSystem {
    name = "sol";
    extraModules = [
      disko.nixosModules.disko
      lanzaboote.nixosModules.lanzaboote
    ];
  };

  zeph = makeSystem {
    name = "zeph";
    isDesktop = true;
    extraModules = [
      disko.nixosModules.disko
      lanzaboote.nixosModules.lanzaboote
    ];
  };

  # Proxmox LXC Container
  rift = makeSystem {
    name = "rift";
    extraModules = [
      modules.system.standalone.hardware.proxmox-lxc
    ];
  };

  # QEMU VMs
  beet = makeSystem {
    name = "beet";
    isAmnesic = true;
    extraModules = [
      disko.nixosModules.disko
      lanzaboote.nixosModules.lanzaboote
    ];
  };
}
