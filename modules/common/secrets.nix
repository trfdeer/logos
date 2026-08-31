{ lib, ... }:
let
  secrets = builtins.path {
    path = ../../.runtime/secrets;
    name = "secrets";
  };

  parsedIdentities = builtins.fromJSON (builtins.readFile "${secrets}/identities.json");
  parsedDevices = builtins.fromJSON (builtins.readFile "${secrets}/devices.json");
  parsedSshHosts = builtins.fromJSON (builtins.readFile "${secrets}/sshHosts.json");
  parsedOutConfig = builtins.fromJSON (builtins.readFile "${secrets}/outConfig.json");

  identityType = lib.types.submodule {
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

  networkConfigType = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "manual"
        ];
        default = "auto";
      };
      manualConfiguration = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              address = lib.mkOption {
                type = lib.types.strMatching ".+/.+";
              };
              gateway = lib.mkOption {
                type = lib.types.str;
              };
              dns = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        );
        default = null;
      };
    };
  };
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
            password_hash = lib.mkOption { type = lib.types.nonEmptyStr; };

            fullname = lib.mkOption {
              type = lib.types.nullOr lib.types.nonEmptyStr;
              default = null;
            };

            git = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    identities = lib.mkOption {
                      type = lib.types.listOf (
                        lib.types.submodule {
                          options = {
                            condition = lib.mkOption { type = lib.types.nonEmptyStr; };
                            config = lib.mkOption { type = identityType; };
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
            hostname = lib.mkOption { type = lib.types.nonEmptyStr; };
            username = lib.mkOption { type = lib.types.nonEmptyStr; };
            identityFiles = lib.mkOption {
              type = lib.types.listOf lib.types.nonEmptyStr;
              default = [ ];
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
              domain = lib.mkOption {
                type = lib.types.nullOr lib.types.nonEmptyStr;
                default = null;
              };
              allowedSshHosts = lib.mkOption {
                type = lib.types.listOf lib.types.nonEmptyStr;
                default = [ ];
              };
              additionalUsers = lib.mkOption {
                type = lib.types.listOf lib.types.nonEmptyStr;
                default = [ ];
              };
              network = lib.mkOption {
                type = lib.types.nullOr networkConfigType;
                default = null;
              };

              networkV6 = lib.mkOption {
                type = lib.types.nullOr networkConfigType;
                default = null;
              };

              initrdSsh = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      bindIp = lib.mkOption {
                        type = lib.types.str;
                        description = "Internal (Tailscale / VPN) IP that ssh in initrd should bind to instead of public IP";
                      };
                    };
                  }
                );
                default = null;
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
