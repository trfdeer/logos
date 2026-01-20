let
  primaryPath = ./primary.nix;
in
if builtins.pathExists primaryPath then
  {
    primary = import primaryPath;
  }
else
  abort ''
    identity not initialized

    run:
      g USERNAME

    this will generate:
      profiles/identities/primary.nix
  ''
