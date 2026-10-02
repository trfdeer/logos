{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.git;
  cfgOp = config.sqwer.home._1password;

  gitIdentityType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };

      email = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };

      sshpubkey = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };
in
{
  options.sqwer.home.git = {
    enable = lib.mkEnableOption "Enable Git";

    identities = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            condition = lib.mkOption { type = lib.types.nonEmptyStr; };
            config = lib.mkOption { type = gitIdentityType; };
          };
        }
      );

      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      signing.signByDefault = true;

      settings = {
        init.defaultBranch = "main";
        user.useConfigOnly = true;
      }
      // lib.optionalAttrs config.sqwer.platform.isWsl {
        core.sshCommand = "ssh.exe";
      }
      // lib.optionalAttrs cfgOp.enable {
        "gpg \"ssh\"".program =
          if (config.sqwer.platform.isWsl) then
            "op-ssh-sign-wsl.exe"
          else if (config.sqwer.platform.isNixosSystem) then
            lib.getExe pkgs._1password-cli
          else
            "/opt/1Password/op-ssh-sign";
      };

      includes = map (identity: {
        condition = identity.condition;

        contents = {
          user = {
            name = identity.config.name;
            email = identity.config.email;
            signingkey = identity.config.sshpubkey;
          };
        }
        // lib.optionalAttrs (identity.config.sshpubkey != "") {
          gpg.format = "ssh";
        };
      }) cfg.identities;
    };
  };
}
