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

    email = lib.mkOption {
      type = lib.types.str;
      description = ''
        Primary email address associated with the user.
        Typically used for Git commits and related tooling.
      '';
    };

    sshPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        SSH public keys used for general-purpose access to remote systems.
        These keys may be installed into authorized_keys for the user.
      '';
    };

    gitSshPublicKey = lib.mkOption {
      type = lib.types.str;
      description = ''
        SSH public key used exclusively for Git authentication.
        Intended for signing or accessing Git remotes when a
        dedicated key is preferred.
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
            sshPubKey = lib.mkOption {
              type = lib.types.nonEmptyStr;
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
      hashedPassword = targetIdentity.password_hash;

      # Handle nullable fullname, fallback to username
      fullName =
        if targetIdentity.fullname != null then targetIdentity.fullname else targetIdentity.username;

      # Handle nullable git.email, fallback to empty string or username
      email = if targetIdentity ? git && targetIdentity.git ? email then targetIdentity.git.email else "";

      # SSH Keys
      sshPublicKeys =
        if targetIdentity ? ssh && targetIdentity.ssh ? authorized_keys then
          targetIdentity.ssh.authorized_keys
        else
          [ ];

      # Git SSH Key
      gitSshPublicKey =
        if targetIdentity ? git && targetIdentity.git ? sshpubkey then targetIdentity.git.sshpubkey else "";

      # Map sshHosts list to attrs
      sshHosts = lib.listToAttrs (
        map (host: {
          name = host.alias;
          value = {
            domain = host.hostname;
            user = host.username;
            sshPubKey = host.sshPubkey;
          };
        }) config.sqwer.secrets.sshHosts
      );
    };
  };
}
