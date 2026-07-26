{ lib, ... }:
{
  options.sqwer.platform = {
    stateVersion = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "System and Home Manager state version.";
    };

    hostName = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };

    roles = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "desktop"
          "server"

          "dev"
        ]
      );
    };

    isWsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indicates that the Home Manager configuration is running inside
        Windows Subsystem for Linux (WSL).

        Used by other modules to apply WSL-specific behavior or workarounds.
      '';
    };

    isNixosSystem = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indiciates whether this is a nixos-system or a home-manager only config.
      '';
    };
  };
}
