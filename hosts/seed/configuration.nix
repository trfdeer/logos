{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
  ];
  installer.cloneConfig = false;

  boot.kernelParams = [ "console=ttyS0,115200" ];
  networking.hostName = "seed";

  sqwer.system.ssh.enable = true;
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = id.sshPublicKeys;
  users.users.${id.username}.openssh.authorizedKeys.keys = id.sshPublicKeys;

  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
  ];

  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
