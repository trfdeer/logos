{ lib, config, ... }:
{
  options = {
    sqwer.tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale";
      operator = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Set tailscale operator";
      };
      advertiseRoutes = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Advertise subnet routes";
      };
    };
  };

  config = lib.mkIf config.sqwer.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--ssh=false"
        "--accept-dns=true"
        "--accept-routes=true"
        "--netfilter-mode=nodivert"
        "--operator=${config.sqwer.tailscale.operator}"
      ]
      ++ lib.optionals (config.sqwer.tailscale.advertiseRoutes != "") [
        "--advertise-routes=${config.sqwer.tailscale.advertiseRoutes}"
        "--snat-subnet-routes=false"
      ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

    boot.kernel.sysctl = lib.mkIf (config.sqwer.tailscale.advertiseRoutes != "") {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.default.forwarding" = true;
    };
  };
}
