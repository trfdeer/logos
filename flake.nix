{
  description = "NixOS / Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
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
          isDesktop = true;
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

           fallback_key="$root/profiles/identities/key.age"

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

           # try normal decryption first
           if ! decrypted=$(sops -d "$secrets" 2>/dev/null); then
             echo "Normal key decryption failed, using fallback passphrase key..." >&2

             # create temporary key file
             tmp_key=$(mktemp)
             trap 'shred -u "$tmp_key"' EXIT

             # decrypt passphrase-wrapped fallback key
             age -d "$fallback_key" > "$tmp_key"
             export SOPS_AGE_KEY_FILE="$tmp_key"

             # decrypt SOPS secrets
             decrypted=$(sops -d "$secrets")
           fi

          echo "$decrypted" | gomplate \
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
