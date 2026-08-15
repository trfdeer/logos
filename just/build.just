set default-list

ROOT := justfile_directory()

# Build system images

# Build system image (requires OUTPUT and TYPE)
image OUTPUT TYPE *ARGS:
    cd {{ROOT}} && nix build "{{ROOT}}#nixosConfigurations.{{OUTPUT}}.config.system.build.{{TYPE}}" {{ARGS}}

# Build LXC container image tarball
lxc OUTPUT *ARGS:
    cd {{ROOT}} && just build image {{OUTPUT}} tarball {{ARGS}}

# Build ISO image
iso OUTPUT *ARGS:
    cd {{ROOT}} && just build image {{OUTPUT}} isoImage {{ARGS}}

# Build WSL tarball
wsl OUTPUT *ARGS:
    cd {{ROOT}} && just build image {{OUTPUT}} tarballBuilder {{ARGS}}
