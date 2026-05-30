{
  description = "NixOS / Home Manager Configuration";
  outputs = inputs: import ./outputs inputs;

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";

    preservation.url = "github:nix-community/preservation";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sqpkgs = {
      url = "github:trfdeer/sqpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
