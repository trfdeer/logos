{ lib, config, ... }:
{
  options = { };

  config = {
    home.sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/code/go";

      CARGO_HOME = "${config.xdg.dataHome}/cargo";

      DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;

      GNUPGHOME = "${config.xdg.dataHome}/gnupg";
    }
    // lib.optionalAttrs (config.sqwer.home.k8s.enable == true) {
      KUBECONFIG = "${config.xdg.configHome}/kube/config";
      TALOS_HOME = "${config.xdg.stateHome}/talos";
    }
    // lib.optionalAttrs (lib.elem "desktop" config.sqwer.platform.roles) {
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      RENPY_PATH_TO_SAVES = "${config.xdg.dataHome}/renpy";
    };
  };
}
