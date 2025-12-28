{ lib, ... }:

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

    fullName = lib.mkOption {
      type = lib.types.str;
      description = ''
        User’s full human-readable name.
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
  };
}
