{
  lib,
  config,
  constants,
  ...
}:
{
  options = {
    sqwer.git.enable = lib.mkEnableOption "Enable Git";
  };

  config = lib.mkIf config.sqwer.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName = constants.username;
      userEmail = constants.email;
      signing = {
        key = constants.signingKey;
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
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
