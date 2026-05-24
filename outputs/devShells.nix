{ pkgs, ... }:
{
  default = pkgs.mkShellNoCC {
    packages = with pkgs.unstable; [
      nixd
      nixfmt
      helix

      nh
      git
      just

      age
      sops
    ];
  };
}
