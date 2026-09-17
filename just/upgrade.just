set quiet
set default-list
set unstable

ROOT := justfile_directory()

host(s) := replace_regex(s, ":.*", "")
port(s) := if s =~ ":" { replace_regex(s, "^.*:", "") } else { "22" }

port_flag(s) := if s =~ ":" { "-p " + replace_regex(s, "^.*:", "") } else { "" }
endpoint(s) := "ssh-ng://" + host(s) + if s =~ ":" { ":" + replace_regex(s, "^.*:", "") } else { "" }

# Upgrade OS on remote target
os CONFIG ENDPOINT=CONFIG:
    NIX_SSHOPTS="{{port_flag(ENDPOINT)}}" nh os switch "{{ROOT}}#{{CONFIG}}" --target-host {{host(ENDPOINT)}}

# Upgrade Home Manager on remote target
home CONFIG ENDPOINT=CONFIG:
    home-manager build --flake "{{ROOT}}#{{CONFIG}}"
    nix copy --to {{endpoint(ENDPOINT)}} {{ROOT}}#homeConfigurations."{{CONFIG}}".activationPackage --no-check-sigs
    ssh {{port_flag(ENDPOINT)}} {{host(ENDPOINT)}} "$(nix path-info {{ROOT}}#homeConfigurations.\"{{CONFIG}}\".activationPackage)/activate"

# Install (bootstrap) OS onto target host
install CONFIG ENDPOINT=CONFIG *ARGS:
    nixos-anywhere \
      --target-host "root@{{host(ENDPOINT)}}" \
      {{port_flag(ENDPOINT)}} \
      -f "{{ROOT}}#{{CONFIG}}" \
      {{ARGS}}
