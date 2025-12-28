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

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        sol = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./modules/coreModules

            ./profiles/primary/identity.nix
            ./profiles/platform.nix

            ./modules/nixosModules

            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            lanzaboote.nixosModules.lanzaboote
            determinate.nixosModules.default

            home-manager.nixosModules.home-manager

            ./hosts/sol/configuration.nix
          ];

        };

        rock = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            hostname = "rock";
          };

          modules = [
            ./modules/coreModules

            ./profiles/primary/identity.nix
            ./profiles/platform.nix

            ./modules/nixosModules

            inputs.nixos-wsl.nixosModules.default
            catppuccin.nixosModules.catppuccin
            determinate.nixosModules.default

            home-manager.nixosModules.home-manager

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
