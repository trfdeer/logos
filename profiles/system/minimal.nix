{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/headless.nix"
  ];

  disabledModules = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"
  ];

  boot.initrd = {
    kernelModules = [ "xfs" ];
    includeDefaultModules = false;
  };

  environment.defaultPackages = [ ];
  documentation.enable = false;
  xdg = {
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
