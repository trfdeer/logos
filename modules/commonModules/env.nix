{ lib, ... }:
{
  # Environment and capability flags used for cross-module coordination.
  options.sqwer.env = {
    isWsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indicates that the Home Manager configuration is running inside
        Windows Subsystem for Linux (WSL).

        Used by other modules to apply WSL-specific behavior or workarounds.
      '';
    };

    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indiciates that the Home Manager configuration is running inside
        an interactive desktop environment.
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
