{ lib, config, ... }:
let
  cfg = config.sqwer.system.ssh;
in
{
  options.sqwer.system.ssh = {
    enable = lib.mkEnableOption "Enable SSH";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
