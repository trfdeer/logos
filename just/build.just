set default-list

ROOT := justfile_directory()

# Build system images

# Build system image (requires OUTPUT and TYPE)
image OUTPUT TYPE *ARGS:
    nix build "{{ROOT}}#nixosConfigurations.{{OUTPUT}}.config.system.build.{{TYPE}}" {{ARGS}}

# Build LXC container image tarball
lxc OUTPUT *ARGS:
    just build image {{OUTPUT}} tarball {{ARGS}}

# Build ISO image
iso OUTPUT *ARGS:
    just build image {{OUTPUT}} isoImage {{ARGS}}

# Build WSL tarball
wsl OUTPUT *ARGS:
    just build image {{OUTPUT}} tarballBuilder {{ARGS}}
