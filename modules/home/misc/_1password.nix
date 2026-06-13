{
  lib,
  config,
  pkgs,
  ...
}:
let
  id = config.sqwer.identity;
  cfgHome = config.sqwer.home;
  sqPlatform = config.sqwer.platform;

  opSshSignPath =
    if sqPlatform.isWsl then
      "/mnt/c/Users/${id.username}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe"
    else if sqPlatform.isNixosSystem then
      "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}"
    else
      "/opt/1Password/op-ssh-sign";

in
{
  options.sqwer.home._1password = {
    enable = lib.mkEnableOption "1Password User Config";
  };

  config = lib.mkIf cfgHome._1password.enable (
    lib.mkMerge [
      (lib.mkIf cfgHome.git.enable {
        programs.git.settings."gpg \"ssh\"".program = opSshSignPath;
      })
      (lib.mkIf cfgHome.ssh.enable {
        programs.ssh.settings."*".IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
      })
    ]
  );
}
