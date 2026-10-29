{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.git;
  cfgOp = config.logos.home._1password;

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
  options.logos.home.git = {
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
      # Use the same git as `pkgs.unstable.mise` to avoid a second git in the closure.
      package = pkgs.unstable.git;
      lfs.enable = true;
      signing.signByDefault = false;

      settings = {
        init.defaultBranch = "main";
        user.useConfigOnly = true;
      }
      // lib.optionalAttrs config.logos.platform.isWsl {
        core.sshCommand = "ssh.exe";
      }
      // lib.optionalAttrs cfgOp.enable {
        "gpg \"ssh\"".program =
          if (config.logos.platform.isWsl) then
            "op-ssh-sign-wsl.exe"
          else if (config.logos.platform.isNixosSystem) then
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
