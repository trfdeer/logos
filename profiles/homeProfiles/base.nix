{ config, ... }:
let
  id = config.sqwer.identity;
in
{
  home = {
    username = id.username;
    homeDirectory = "/home/${id.username}";
    stateVersion = config.sqwer.platform.stateVersion;
  };

  xdg.enable = true;
  xdg.mime.enable = true;

  sqwer = {
    git.user = {
      name = id.fullName;
      email = id.email;
      signingkey = id.gitSshPublicKey;
    };
  };
}
# // lib.optionalAttrs (!config.sqwer.env.isNixosSystem) {
#   nixpkgs.config.allowUnfree = true;

#   nix.settings = {
#     use-xdg-base-directories = true;
#     auto-optimise-store = true;
#     experimental-features = [
#       "nix-command"
#       "flakes"
#     ];
#     trusted-users = [ id.username ];
#   };

#   programs.home-manager.enable = true;
# }
