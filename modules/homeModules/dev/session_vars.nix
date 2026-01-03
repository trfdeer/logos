{ config, ... }:
{
  options = { };

  config = {
    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/code/go";

      CARGO_HOME = "${config.xdg.dataHome}/cargo";

      DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    };
  };
}
