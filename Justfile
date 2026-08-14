set shell := ['bash', '-cu']
set positional-arguments

# secet management
mod secrets './just/secrets.just'

# build images
mod build './just/build.just'

# upgrade / install targets
mod upgrade './just/upgrade.just'

@_default:
  just --list --list-submodules
