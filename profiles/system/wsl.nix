{ config, modulesPath, ... }:
let
  id = config.sqwer.identity;
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

  sqwer = {
    platform.isWsl = true;
    system.boot.doNotConfigure = true;
  };

  documentation.enable = false;
}
