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
  };
}
