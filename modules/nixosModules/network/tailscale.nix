{ lib, config, ... }:
let
  cfg = config.sqwer.system.tailscale;
in
{
  options.sqwer.system.tailscale = {
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
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkIf (cfg.advertiseRoutes != "") "both";
      extraSetFlags = [
        "--ssh=false"
        "--accept-dns=true"
        "--accept-routes=true"
        "--netfilter-mode=nodivert"
      ]
      ++ lib.optionals (cfg.operator != "") [
        "--operator=${cfg.operator}"
      ]
      ++ lib.optionals (cfg.advertiseRoutes != "") [
        "--advertise-routes=${cfg.advertiseRoutes}"
        "--snat-subnet-routes=false"
      ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

    boot.kernel.sysctl = lib.mkIf (cfg.advertiseRoutes != "") {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.default.forwarding" = true;
    };
  };
}
