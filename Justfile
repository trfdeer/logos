set lazy
set positional-arguments

# secret management
mod secret './just/secret.just'

# build images
mod build './just/build.just'

# upgrade / install targets
mod upgrade './just/upgrade.just'

@_default:
  just --list --list-submodules
