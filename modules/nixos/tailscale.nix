{ lib, config, ... }:
{
  options = {
    sqwer.tailscale.enable = lib.mkEnableOption "Enable Tailscale";
  };

  config = lib.mkIf config.sqwer.tailscale.enable {
    services.tailscale = {
      enable = true;
      extraSetFlags = [
        "--netfilter-mode=nodivert"
        "--no-logs-no-support"
      ];
    };
  };
}
