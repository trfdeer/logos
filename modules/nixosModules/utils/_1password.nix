{ lib, config, ... }:
let
  cfg = config.sqwer.system._1password;
in
{
  options.sqwer.system._1password = {
    enable = lib.mkEnableOption "1Password Password Manager";
    systemUsers = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = "List if users allowed to use CLI integration / system authentiation";
    };
  };

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = cfg.systemUsers;
    };
  };
}
