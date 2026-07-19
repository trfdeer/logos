{
  lib,
  config,
  ...
}:
let
  cfg = config.sqwer.home.git;

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
    identity = lib.mkOption { type = gitIdentityType; };

    additionalIdentities = lib.mkOption {
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
      signing = {
        key = cfg.identity.sshpubkey;
        signByDefault = cfg.identity.sshpubkey != "";
      };

      settings = {
        user = {
          name = cfg.identity.name;
          email = cfg.identity.email;
        };
        init.defaultBranch = "main";
        gpg.format = lib.mkIf (cfg.identity.sshpubkey != "") "ssh";
      }
      // lib.optionalAttrs config.sqwer.platform.isWsl {
        core.sshCommand = "ssh.exe";
      };

      includes = map (identity: {
        condition = identity.condition;

        contents = {
          user = {
            name = identity.config.name;
            email = identity.config.email;
            signingkey = identity.config.sshpubkey;
          };
          gpg = lib.optionalAttrs (identity.config.sshpubkey != "") {
            format = "ssh";
          };
        };
      }) cfg.additionalIdentities;
    };
  };
}
