{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      constants = {
        name = "REDACTED_NAME";
        username = "REDACTED_USERNAME";
        email = "REDACTED_EMAIL";
        signingKey = "REDACTED_SSH_KEY";
        sshKeys = [ "REDACTED_SSH_KEY" ];
        stateVersion = "25.11";
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # ================================================================
      # Test VM Config
      # ================================================================
      nixosConfigurations.nixvm1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          ./hosts/wsl/configuration.nix
          ./modules/nixos
        ];
      };

      # ================================================================
      # WSL Config
      # ================================================================
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./hosts/wsl/configuration.nix
          ./modules/nixos
        ];
      };

      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit constants inputs; };

        modules = [
          ./modules/home-manager
          ./home.nix
          {
            sqwer = {
              git._1password.isWsl = true;
            };
          }
        ];
      };

      # ================================================================
      # sol Config
      # ================================================================
      nixosConfigurations.sol = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          lanzaboote.nixosModules.lanzaboote

          ./hosts/sol/configuration.nix
          ./modules/nixos
        ];
      };

      homeConfigurations.sol = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit constants inputs; };

        modules = [
          ./modules/home-manager
          ./home.nix
          {
            sqwer = {
              git._1password.enable = false;
            };
          }
        ];

      };

      # ================================================================
      # rock Config
      # ================================================================
      homeConfigurations.rock = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit constants inputs; };

        modules = [
          ./modules/home-manager
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
