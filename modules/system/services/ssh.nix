{ lib, config, ... }:
let
  cfg = config.sqwer.system.ssh;
in
{
  options.sqwer.system.ssh = {
    enable = lib.mkEnableOption "Enable SSH";
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
