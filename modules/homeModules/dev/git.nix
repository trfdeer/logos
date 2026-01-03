{
  lib,
  config,
  ...
}:
let
  homeCfg = config.sqwer.home;
in
{
  options.sqwer.home.git = {
    enable = lib.mkEnableOption "Enable Git";
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user name";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user email";
      };
      signingkey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user signingkey";
      };
    };
  };

  config = lib.mkIf homeCfg.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      signing = {
        key = homeCfg.git.user.signingkey;
        signByDefault = homeCfg.git.user.signingkey != "";
      };
      settings = {
        user = {
          name = homeCfg.git.user.name;
          email = homeCfg.git.user.email;
        };
        init.defaultBranch = "main";
        gpg.format = lib.mkIf (homeCfg.git.user.signingkey != "") "ssh";
      }
      // lib.optionalAttrs (homeCfg.git.user.signingkey != "" && config.sqwer.env.has1Password) {
        "gpg \"ssh\"".program =
          if config.sqwer.env.isWsl then
            ''/mnt/c/Program Files/1Password/app/8/op-ssh-sign-wsl''
          else
            "/opt/1Password/op-ssh-sign";
      }
      // lib.optionalAttrs config.sqwer.env.isWsl {
        core.sshCommand = "ssh.exe";
      };
    };
  };
}
