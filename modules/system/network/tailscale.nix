{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.system.tailscale;
in
{
  options.logos.system.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale";
    operator = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Set tailscale operator";
    };
    advertiseRoutes = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Advertise subnet routes";
    };
    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Accept routes";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      disableUpstreamLogging = true;
      useRoutingFeatures = if cfg.advertiseRoutes != "" then "both" else "none";

      extraSetFlags = [
        "--ssh=false"
        "--accept-dns=true"
        "--netfilter-mode=nodivert"
      ]
      ++ lib.optionals (cfg.operator != "") [
        "--operator=${cfg.operator}"
      ]
      ++ lib.optionals (cfg.advertiseRoutes != "") [
        "--advertise-routes=${cfg.advertiseRoutes}"
        "--snat-subnet-routes=false"
      ]
      ++ lib.optionals (cfg.acceptRoutes) [
        "--accept-routes=true"
      ];
    };
  };
}
