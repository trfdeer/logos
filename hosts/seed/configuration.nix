{
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

  networking.hostName = "seed";

  sqwer.system.ssh.enable = true;

  users.users.${id.username}.openssh.authorizedKeys.keys = id.sshPublicKeys;
  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
  ];
}
