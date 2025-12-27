{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
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
      self,
      disko,
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

            sqwer.nixosModules
            ./hosts/sol/configuration.nix
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs constants sqwer; };

          modules = [
            inputs.nixos-wsl.nixosModules.default
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager

            sqwer.nixosModules
            ./hosts/wsl/configuration.nix
          ];
        };
      };

      homeConfigurations.rock = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit constants inputs sqwer; };

        modules = [
          sqwer.homeModules
          catppuccin.nixosModules.catppuccin

          ./home.nix
          {
            sqwer = {
              audio.disable-hsp = true;
              audio.disable-hw-volume = true;
              tmux.prefixKey = "C-a";
            };
          }
        ];
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
