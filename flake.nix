{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      constants = {
        username = "ttarafder";
        email = "ttarafder7d1@protonmail.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNyNZFAlLgqaLZGIB79Gz/FT0rj9PcIYW6zaM4fhUhb";
        stateVersion = "25.05";
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixvm1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          ./hosts/nixvm1/configuration.nix
          ./modules/nixos
        ];
      };

      homeConfigurations.${constants.username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit constants inputs; };

        modules = [
          ./home.nix
          ./modules/home-manager
        ];
      };
    };
}
