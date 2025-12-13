{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
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
      nixosConfigurations.nixvm1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          ./hosts/wsl/configuration.nix
          ./modules/nixos
        ];
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs constants; };

        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./hosts/wsl/configuration.nix
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

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nixd
          nixfmt-rfc-style
        ];
      };
    };
}
