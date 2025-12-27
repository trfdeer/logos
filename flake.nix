{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      disko,
      determinate,
      nixpkgs,
      lanzaboote,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      constants = {
        name = "Tuhin Tarafder";
        username = "ttarafder";
        email = "ttarafder7d1@protonmail.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNyNZFAlLgqaLZGIB79Gz/FT0rj9PcIYW6zaM4fhUhb";
        sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBod7BQCA2N5GCdkD8NJzjhx5uajVrUwNCok+EYtDAvA" ];
        stateVersion = "25.11";
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      sqwer = {
        homeModules = import ./modules/homeModules;
        nixosModules = import ./modules/nixosModules;
      };
    in
    {
      nixosConfigurations = {
        sol = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs constants sqwer; };

          modules = [
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            determinate.nixosModules.default

            sqwer.nixosModules
            ./hosts/sol/configuration.nix
          ];
        };

        rock = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs constants sqwer;
            hostname = "rock";
          };

          modules = [
            inputs.nixos-wsl.nixosModules.default
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            determinate.nixosModules.default

            sqwer.nixosModules
            ./hosts/wsl/configuration.nix
          ];
        };
      };

      # ================================================================
      # Dev Shell
      # ================================================================
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nixd
          nixfmt-rfc-style
        ];
      };
    };
}
