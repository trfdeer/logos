{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfgHome = config.sqwer.home;
  sqEnv = config.sqwer.env;

  opSshSignPath =
    if sqEnv.isWsl then
      "/mnt/c/Program Files/1Password/app/8/op-ssh-sign-wsl"
    else if sqEnv.isNixosSystem then
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
      (lib.mkIf cfgHome.ssh.enable {
        programs.ssh.matchBlocks."*".identityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
      })
      (lib.mkIf cfgHome.git.enable {
        programs.git.settings."gpg \"ssh\"".program = opSshSignPath;
      })
    ]
  );
}
