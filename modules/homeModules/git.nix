{
  lib,
  config,
  ...
}:
{
  options.sqwer.git = {
    enable = lib.mkEnableOption "Enable Git";
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Git user name";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Git user email";
      };
      signingkey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user signingkey";
      };
    };
  };

  config = lib.mkIf config.sqwer.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      signing = {
        key = config.sqwer.git.user.signingkey;
        signByDefault = config.sqwer.git.user.signingkey != "";
      };
      settings = {
        user = {
          name = config.sqwer.git.user.name;
          email = config.sqwer.git.user.email;
        };
        init.defaultBranch = "main";
        gpg.format = lib.mkIf (config.sqwer.git.user.signingkey != "") "ssh";
      }
      // lib.optionalAttrs (config.sqwer.git.user.signingkey != "" && config.sqwer.env.has1Password) {
        "gpg \"ssh\"".program =
          if config.sqwer.env.isWsl then
            "/mnt/c/Program\\ Files/1Password/app/8/op-ssh-sign-wsl"
          else
            "/opt/1Password/op-ssh-sign";
      }
      // lib.optionalAttrs config.sqwer.env.isWsl {
        core.sshCommand = "ssh.exe";
      };
    };
  };
}
