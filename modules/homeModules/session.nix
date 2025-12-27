{ config, ... }:
{
  options = { };

  config = {
    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/code/go";
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    };
  };
}
