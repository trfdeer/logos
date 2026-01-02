{ lib, ... }:
{
  # Environment and capability flags used for cross-module coordination.
  options.sqwer.env = {
    has1Password = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indicates that 1Password is installed and available on the system.

        This option does not perform any configuration by itself; it is consumed
        by other modules (e.g. git, ssh) to enable 1Password-backed integrations
        such as SSH authentication or commit signing.
      '';
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

    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Indiciates that the Home Manager configuration is running inside
        an inderactive desktop environment.
      '';
    };
  };
}
