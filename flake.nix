{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

  outputs =
    {
      self,
      disko,
      nixpkgs,
      nixpkgsUnstable,
      lanzaboote,
      sqpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ sqpkgs.overlays.default ];
      };

      pkgsUnstable = import nixpkgsUnstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ sqpkgs.overlays.default ];
      };

      modules = import ./modules;
      profiles = import ./profiles;
      hosts = import ./hosts;

      mkHost = import ./flake/mk-host.nix {
        lib = pkgs.lib;
        inherit
          nixpkgs
          inputs
          modules
          profiles
          system
          hosts
          ;
      };

      mkHome = import ./flake/mk-home.nix {
        inherit
          pkgs
          modules
          profiles
          inputs
          ;
      };

    in
    {
      nixosConfigurations = {
        sol = mkHost {
          name = "sol";
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        zeph = mkHost {
          name = "zeph";
          isDesktop = true;
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        # # Proxmox LXC Container
        # rift = mkHost {
        #   name = "rift";
        #   extraModules = [
        #     modules.nixosModules.standalone.hardware.proxmox-lxc
        #   ];
        # };
      };

      # homeConfigurations = {
      #   primary = mkHome {
      #     extraModules = [
      #       profiles.home.desktop
      #     ];
      #   };
      # };

      # ================================================================
      # Dev Shell
      # ================================================================
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages =
          with pkgs;
          [
            age
            sops
            helix
            gomplate
            ssh-to-age
            git

            nixd
            nixfmt-rfc-style
          ]
          ++ (with pkgsUnstable; [
            just
            nh
          ]);
      };
    };
}
