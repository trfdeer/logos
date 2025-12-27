{
  lib,
  config,
  ...
}:
{
  options = {
    sqwer.git.enable = lib.mkEnableOption "Enable Git";
    sqwer.git.user = {
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
        description = "Git user signingkey";
      };
    };

    sqwer.git._1password = {
      enable = lib.mkEnableOption "Enable 1Password integration";
      isWsl = lib.mkEnableOption "Use windows 1Password path";
    };
  };

  config = lib.mkIf config.sqwer.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      signing = {
        key = config.sqwer.git.user.signingkey;
        signByDefault = true;
      };
      settings = {
        user = {
          name = config.sqwer.git.user.name;
          email = config.sqwer.git.user.email;
        };
        init.defaultBranch = "main";
        gpg.format = "ssh";
      }
      // lib.optionalAttrs config.sqwer.git._1password.enable {
        "gpg \"ssh\"".program =
          if config.sqwer.git._1password.isWsl then
            "/mnt/c/Program\ Files/1Password/app/8/op-ssh-sign-wsl"
          else
            "/opt/1Password/op-ssh-sign";
      }
      // lib.optionalAttrs config.sqwer.git._1password.isWsl {
        core.sshCommand = "ssh.exe";
      };
    };
  };
}
