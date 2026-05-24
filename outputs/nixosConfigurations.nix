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

  # # Proxmox LXC Container
  # rift = makeSystem {
  #   name = "rift";
  #   extraModules = [
  #     modules.nixosModules.standalone.hardware.proxmox-lxc
  #   ];
  # };
}
