{
  lib,
  config,
  pkgs,
  ...
}:
let
  homeCfg = config.sqwer.home;
in
{
  options.sqwer.home.nix = {
    enable = lib.mkEnableOption "Configure nix and enable home-manager";
  };

  config = lib.mkIf (homeCfg.nix.enable && !config.sqwer.env.isNixosSystem) {
    nix = {
      package = pkgs.nix;
      settings = {
        use-xdg-base-directories = true;
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Can't set these from home config
        # trusted-users = [ config.sqwer.identity.username ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    programs.home-manager.enable = true;
  };
}
