{ lib, config, ... }:
let
  currentHostname = config.sqwer.platform.hostName;
  hostConfig =
    if config.sqwer.secrets.outConfig ? ${currentHostname} then
      config.sqwer.secrets.outConfig.${currentHostname}
    else
      throw "No configuration found for hostname '${currentHostname}' in outConfig.json. Available: ${lib.concatStringsSep ", " (lib.attrNames config.sqwer.secrets.outConfig)}";

  # 3. Get the target user ID
  targetUserId = hostConfig.defaultUser;

  # 4. Find the identity in the secrets list
  targetIdentity = lib.findFirst (id: id._id == targetUserId) null config.sqwer.secrets.identities;

  gitGitPrimaryIdCfg =
    fieldName:
    if
      targetIdentity ? git
      && targetIdentity.git ? primaryIdentity
      && targetIdentity.git.primaryIdentity ? "${fieldName}"
    then
      targetIdentity.git.primaryIdentity."${fieldName}"
    else
      "";

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
  options.sqwer.identity = {
    username = lib.mkOption {
      type = lib.types.str;
      description = ''
        Primary local username for the human user.
        Used for Home Manager configuration, home directory paths,
        and user-scoped settings.
      '';
    };

    hashedPassword = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = ''
        Hashed password for the human user.
        Created using `mkpasswd` utility.
      '';
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      description = ''
        User's full human-readable name.
        Intended for use in Git configuration, SSH metadata,
        and other identity-related contexts.
      '';
    };

    git = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            primaryIdentity = lib.mkOption { type = gitIdentityType; };

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
        }
      );
      default = null;
    };

    sshPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        SSH public keys used for general-purpose access to remote systems.
        These keys may be installed into authorized_keys for the user.
      '';
    };

    sshHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            domain = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
            user = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
            identityFiles = lib.mkOption {
              type = lib.types.listOf lib.types.nonEmptyStr;
            };
          };
        }
      );
      default = { };
      description = ''
        Identity-scoped SSH hosts.
        Typically used for Git remotes or other personal access patterns.
      '';
    };

  };

  config = {
    assertions = [
      {
        assertion = config.sqwer.secrets.outConfig ? ${currentHostname};
        message = "Missing host config for '${currentHostname}' in outConfig.json";
      }
      {
        assertion = targetIdentity != null;
        message = "User '${targetUserId}' not found in identities.json";
      }
    ];

    sqwer.identity = {
      username = targetIdentity.username;
      fullName = if targetIdentity.fullname == null then "" else targetIdentity.fullname;
      hashedPassword = targetIdentity.password_hash;

      inherit (targetIdentity) git;

      # SSH Keys
      sshPublicKeys =
        if targetIdentity ? ssh && targetIdentity.ssh ? authorized_keys then
          targetIdentity.ssh.authorized_keys
        else
          [ ];

      # Map sshHosts list to attrs
      sshHosts = lib.listToAttrs (
        map (host: {
          name = host.alias;
          value = {
            domain = host.hostname;
            user = host.username;
            identityFiles = host.identityFiles;
          };
        }) config.sqwer.secrets.sshHosts
      );
    };
  };
}
