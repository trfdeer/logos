inputs@{
  nixpkgs,
  nixpkgsUnstable,
  sqpkgs,
  ...
}:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      sqpkgs.overlays.default
      (final: prev: {
        unstable = import nixpkgsUnstable {
          inherit system;
          config.allowUnfree = true;
        };
      })
    ];
  };

  commonInherits = {
    inherit pkgs inputs;

    utils = import ../utils;
    modules = import ../modules;
    profiles = import ../profiles;
    hosts = import ../hosts;
  };

in
{
  devShells.${system} = import ./devShells.nix { inherit pkgs; };
  formatter.${system} = pkgs.nixfmt-tree;

  homeConfigurations = import ./homeConfigurations.nix commonInherits;
  nixosConfigurations = import ./nixosConfigurations.nix commonInherits;
}
