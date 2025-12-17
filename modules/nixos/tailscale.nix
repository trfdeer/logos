{ lib, config, ... }:
{
  options = {
    sqwer.tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale";
      operator = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Set tailscale operator";
      };
    };
  };

  config = lib.mkIf config.sqwer.tailscale.enable {
    services.tailscale = {
      enable = true;
      extraSetFlags = [
        "--ssh"
        "--accept-dns"
        "--accept-routes"
        "--netfilter-mode=nodivert"
        "--operator=${config.sqwer.tailscale.operator}"
      ];
    };
  };
}
