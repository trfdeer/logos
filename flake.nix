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
    sqpkgs = {
      url = "git+ssh://git@github.com/trfdeer/sqpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      disko,
      nixpkgs,
      lanzaboote,
      sqpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          sqpkgs.overlays.default
          (import ./overlays/terraria-server-1.4.5.0-master-412d8dd.nix)
        ];
      };

      modules = import ./modules;
      profiles = import ./profiles;
      hosts = import ./hosts;

      mkHost = import ./flake/mk-host.nix {
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

        rock = mkHost {
          name = "rock";
          extraModules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        # Proxmox LXC Container
        rift = mkHost {
          name = "rift";
          extraModules = [
            modules.nixosModules.standalone.hardware.proxmox-lxc
          ];
        };

        # Proxmox VM
        atlas = mkHost {
          name = "atlas";
          extraModules = [
            disko.nixosModules.disko
          ];
        };
      };

      homeConfigurations = {
        primary = mkHome {
          extraModules = [
            profiles.home.desktop
          ];
        };
      };

      packages.${system}.gi = pkgs.writeShellApplication {
        name = "gi";
        runtimeInputs = [
          pkgs.sops
          pkgs.gomplate
          pkgs.git
        ];

        text = ''
          set -euo pipefail

          # find repo root from current directory
          root="$(git rev-parse --show-toplevel)"

          secrets="$root/profiles/identities/secrets.json"
          template="$root/profiles/identities/primary.nix.tmpl"
          output="$root/profiles/identities/primary.nix"

          user=""

          case "''${1:-}" in
            -u)
              read -rp "identity username: " user
              ;;
            "")
              user="$USER"
              ;;
            *)
              user="$1"
            ;;
          esac

          export GI_USER="$user"

          sops -d "$secrets" \
          | gomplate \
              -d 'identities=stdin:///?type=application/json' \
              -d 'user=env:///GI_USER?type=application/text' \
              -f "$template" \
          > "$output"

          # Make the generated file visible to flakes without staging contents
          git add -fN "$output"

          echo "generated $output for '$user'"
        '';
      };

      # ================================================================
      # Dev Shell
      # ================================================================
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          age
          sops
          helix
          gomplate
          ssh-to-age
          git
          self.packages.${system}.gi

          nixd
          nixfmt-rfc-style
        ];
      };
    };
}
