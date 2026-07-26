{ pkgs, ... }:
{
  default = pkgs.mkShellNoCC {
    packages = with pkgs.unstable; [
      nixd
      nixfmt
      helix

      nh
      git
      go-task

      age
      sops

      nixos-anywhere
    ];
  };
}
