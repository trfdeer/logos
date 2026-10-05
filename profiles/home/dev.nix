{ lib, config, ... }:
let
  id = config.logos.identity;
in
{
  logos.home = {
    utils.dev = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;

    git = {
      enable = lib.mkDefault true;
      inherit (id.git) identities;
    };
  };
}
