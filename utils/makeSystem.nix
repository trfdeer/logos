{
  lib,
  pkgs,
  inputs,
  modules,
  profiles,
  hosts,
}:
{
  name,
  prefs ? { },
  extraModules ? [ ],
  extraSpecialArgs ? { },
}:
let
  prefs' = {
    isWsl = false;
    isLxc = false;

    isDesktop = false;
  }
  // prefs;
in
inputs.nixpkgs.lib.nixosSystem {
  system = pkgs.stdenv.hostPlatform.system;

  specialArgs = {
    inherit inputs modules profiles;

    isDesktop = prefs'.isDesktop;
    hostname = name;
  }
  // extraSpecialArgs;

  modules = [
    { nixpkgs = { inherit pkgs; }; }

    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.preservation.nixosModules.preservation
    inputs.home-manager.nixosModules.home-manager

    modules.common
    modules.system.sqwerSystem

    hosts.${name}
    profiles.platform
    profiles.system.base
  ]
  ++ lib.optional prefs'.isDesktop profiles.system.desktop
  ++ lib.optional prefs'.isLxc modules.system.standalone.hardware.proxmox-lxc
  ++ lib.optionals prefs'.isWsl [
    inputs.nixos-wsl.nixosModules.default
    profiles.system.wsl
  ]
  ++ extraModules;
}
