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

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      modules = import ./modules;
      profiles = import ./profiles;
      hosts = import ./hosts;

      mkHost =
        {
          name,
          extraModules ? [ ],
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs modules profiles;
            hostname = name;
          }
          // extraSpecialArgs;

          modules = [
            hosts.${name}

            modules.commonModules
            profiles.identities.primary
            profiles.platform

            modules.nixosModules.sqwerSystem

            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager

            profiles.system.base
          ]
          ++ extraModules;
        };

      mkHome =
        {
          extraModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            modules.commonModules
            modules.homeModules.standalone.nix
            profiles.identities.primary
            profiles.platform

            catppuccin.homeModules.catppuccin

            modules.homeModules.sqwerHome
            profiles.home.base
          ]
          ++ extraModules;
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
        slate = mkHost {
          name = "slate";
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
        REDACTED_USERNAME = mkHome {
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

          user="''${1:-}"

          if [ -z "$user" ]; then
            read -rp "identity username: " user
          fi

          export GI_USER="$user"

          sops -d "$secrets" \
          | gomplate \
              -d 'identities=stdin:///?type=application/json' \
              -d 'user=env:///GI_USER?type=application/text' \
              -f "$template" \
          > "$output"

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
          self.packages.${system}.gi

          nixd
          nixfmt-rfc-style
        ];
      };
    };
}
