# Upgrade targets in place
set default-list

PORT := "22"
ROOT := justfile_directory()

# Upgrade OS on remote target
os CONFIG HOST=CONFIG:
    nh os switch "{{ROOT}}#{{CONFIG}}" --target-host {{HOST}}

# Upgrade Home Manager on remote target
home CONFIG HOST=CONFIG:
    home-manager build --flake "{{ROOT}}#{{CONFIG}}"
    nix copy --to ssh-ng://{{HOST}} {{ROOT}}#homeConfigurations."{{CONFIG}}".activationPackage
    ssh {{HOST}} "$(nix path-info {{ROOT}}#homeConfigurations.\"{{CONFIG}}\".activationPackage)/activate"

# Install (bootstrap) OS onto target host
install CONFIG HOST=CONFIG PORT=PORT *ARGS:
    nixos-anywhere \
      --target-host "root@{{HOST}}" \
      -p "{{PORT}}" \
      -f "{{ROOT}}#{{CONFIG}}" \
      {{ARGS}}
