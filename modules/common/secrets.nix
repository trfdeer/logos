{ lib, ... }:
let
  secrets = builtins.path {
    path = ../../secrets/decrypted;
    name = "secrets";
  };

  parsedIdentities = builtins.fromJSON (builtins.readFile "${secrets}/identities.json");
  parsedDevices = builtins.fromJSON (builtins.readFile "${secrets}/devices.json");
  parsedSshHosts = builtins.fromJSON (builtins.readFile "${secrets}/sshHosts.json");
  parsedOutConfig = builtins.fromJSON (builtins.readFile "${secrets}/outConfig.json");
in
{
  options.sqwer.secrets = {
    identities = lib.mkOption {
      type = lib.types.nonEmptyListOf (
        lib.types.submodule {
          options = {
            _id = lib.mkOption { type = lib.types.nonEmptyStr; };
            username = lib.mkOption { type = lib.types.nonEmptyStr; };
            is_system_account = lib.mkOption { type = lib.types.bool; };

            fullname = lib.mkOption {
              type = lib.types.nullOr lib.types.nonEmptyStr;
              default = null;
            };

            git = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    email = lib.mkOption { type = lib.types.nonEmptyStr; };
                    sshpubkey = lib.mkOption { type = lib.types.nonEmptyStr; };
                  };
                }
              );
              default = null;
            };

            ssh = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    authorized_keys = lib.mkOption {
                      type = lib.types.listOf lib.types.nonEmptyStr;
                      default = [ ];
                    };
                  };
                }
              );
              default = null;
            };
          };
        }
      );
    };

    devices = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              drive_paths = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = { };
              };

            };
          }
        )
      );
      default = { };
    };

    sshHosts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            _id = lib.mkOption { type = lib.types.nonEmptyStr; };
            alias = lib.mkOption { type = lib.types.nonEmptyStr; };
            username = lib.mkOption { type = lib.types.nonEmptyStr; };
            sshPubkey = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
          };
        }
      );
    };

    outConfig = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              defaultUser = lib.mkOption {
                type = lib.types.str;
              };
              allowedSshHosts = lib.mkOption {
                type = lib.types.listOf lib.types.nonEmptyStr;
                default = [ ];
              };
              additionalUsers = lib.mkOption {
                type = lib.types.listOf lib.types.nonEmptyStr;
                default = [ ];
              };
            };
          }
        )
      );
    };
  };

  config = {
    sqwer.secrets = {
      identities = parsedIdentities.identities;
      devices = parsedDevices.devices;
      sshHosts = parsedSshHosts.sshHosts;
      outConfig = parsedOutConfig.outputs;
    };
  };
}
