{ pkgs, ... }:
{
  default = pkgs.mkShellNoCC {
    packages = with pkgs.unstable; [
      nixd
      nixfmt
      helix

      nh
      git

      age
      sops

      deploy-rs
      nixos-anywhere
    ];
  };
}
