{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      disko,
      nixpkgs,
      lanzaboote,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHost =
        {
          hostModules,
          extraModules ? [ ],
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs;
          }
          // extraSpecialArgs;

          modules = [
            ./modules/commonModules
            ./profiles/identities/primary.nix
            ./profiles/platform.nix

            ./modules/nixosModules

            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager

            ./profiles/nixosProfiles/base.nix
          ]
          ++ extraModules
          ++ hostModules;
        };

      mkHome =
        {
          extraModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./modules/commonModules
            ./profiles/identities/primary.nix
            ./profiles/platform.nix

            catppuccin.homeModules.catppuccin

            ./modules/homeModules
            ./profiles/homeProfiles/base.nix
          ]
          ++ extraModules;
        };

    in
    {
      nixosConfigurations = {
        sol = mkHost {
          hostModules = [ ./hosts/sol/configuration.nix ];
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        rock = mkHost {
          hostModules = [ ./hosts/rock/configuration.nix ];
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        slate = mkHost {
          hostModules = [ ./hosts/hyperv/configuration.nix ];
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
          extraSpecialArgs = {
            hostname = "slate";
          };
        };

        rockwsl = mkHost {
          hostModules = [ ./hosts/wsl/configuration.nix ];
          extraModules = [
            inputs.nixos-wsl.nixosModules.default
          ];
          extraSpecialArgs = {
            hostname = "rockwsl";
          };
        };
      };

      homeConfigurations = {
        ttarafder = mkHome {
          extraModules = [
            ./homes/primaryDesktop.nix
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
