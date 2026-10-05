{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.system.tailscale-serve;
  serveConfig = pkgs.writeText "tailscale-serve-port" (toString cfg.port);
in
{
  options.logos.system.tailscale-serve = {
    enable = lib.mkEnableOption "Enable Tailscale";

    port = lib.mkOption {
      type = lib.types.port;
      description = "Serve port on Tailscale";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "Enabling tailscale-serve requires the tailscale service to be enabled.";
      }
    ];

    systemd.paths.tailscale-serve = {
      wantedBy = [ "multi-user.target" ];

      pathConfig = {
        PathChanged = serveConfig;
      };
    };

    systemd.services.tailscale-serve = {
      serviceConfig.Type = "oneshot";

      after = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];

      script = ''
        port="$(${pkgs.coreutils}/bin/cat ${serveConfig})"
        ${config.services.tailscale.package}/bin/tailscale serve --bg "$port"
      '';
    };
  };
}
