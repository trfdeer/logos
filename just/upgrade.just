# Upgrade targets in place

PORT := "22"

# Upgrade OS on remote target
os HOST OUTPUT:
    nh os switch ".#{{OUTPUT}}" --target-host {{HOST}}

# Upgrade Home Manager on remote target
home HOST OUTPUT:
    home-manager build --flake ".#{{OUTPUT}}"
    nix copy --to ssh-ng://{{HOST}} .#homeConfigurations."{{OUTPUT}}".activationPackage
    ssh {{HOST}} "$(nix path-info .#homeConfigurations.\"{{OUTPUT}}\".activationPackage)/activate"

# Install (bootstrap) OS onto target host
install OUTPUT HOST PORT=PORT *ARGS:
    nixos-anywhere \
      --target-host "root@{{HOST}}" \
      -p "{{PORT}}" \
      -f ".#{{OUTPUT}}" \
      {{ARGS}}
