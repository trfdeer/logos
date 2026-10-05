{ lib, config, ... }:
let
  cfg = config.logos.system.ssh;
in
{
  options.logos.system.ssh = {
    enable = lib.mkEnableOption "Enable SSH";
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port";
    };
  };

  config = lib.mkIf cfg.enable {
    # Don't open the SSH port globally; it must be allowed explicitly via a
    # `logos.system.firewall` zone. Otherwise `services.openssh.openFirewall`
    # (default true) injects the port into `networking.firewall.allowedTCPPorts`,
    # punching it through every zone.
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
