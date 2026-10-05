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

      just
      secretspec
      _1password-cli

      deploy-rs
      nixos-anywhere
    ];
  };
}
