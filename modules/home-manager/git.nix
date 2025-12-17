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
        "gpg \"ssh\"".program = "/opt/1Password/op-ssh-sign";
      };
      # // lib.optionalAttrs defs.config.isWsl {
      #   core.sshCommand = "ssh.exe";
      #   "gpg \"ssh\"".program = "/mnt/c/Program Files/1Password/app/8/op-ssh-sign-wsl";
      # }
      # // lib.optionalAttrs (!defs.config.isWsl && defs.desktop.enable) {
      #   "gpg \"ssh\"".program = "/opt/1Password/op-ssh-sign";
      # };
    };
  };
}
