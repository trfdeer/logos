{ config, modulesPath, ... }:
let
  id = config.logos.identity;
in
{
  wsl = {
    enable = true;
    defaultUser = id.username;

    ssh-agent = {
      enable = true;
      users = [ id.username ];
    };
  };

  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/headless.nix"
  ];

  logos = {
    platform.isWsl = true;
    system.boot.doNotConfigure = true;
  };

  documentation.enable = false;
}
