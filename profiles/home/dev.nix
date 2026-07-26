{ lib, config, ... }:
let
  id = config.sqwer.identity;
in
{
  sqwer.home = {
    utils.dev = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;

    git = {
      enable = lib.mkDefault true;
      identity = id.git.primaryIdentity;

      inherit (id.git) additionalIdentities;
    };
  };
}
