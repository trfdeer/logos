# terraria-server 1.4.5.0
# Pinned to nixpkgs master commit 412d8dd5827cbc19a701c5d33c422d98c2eb8f8a
# PR: https://github.com/NixOS/nixpkgs/pull/484458
#
# Remove this overlay once release-25.11 includes terraria-server >= 1.4.5.0

final: prev:
let
  terrariaCommit =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/412d8dd5827cbc19a701c5d33c422d98c2eb8f8a.tar.gz";
        # Fill in after first build:
        sha256 = "sha256:01jrbl9y2c9cfsdy0i3zfpbq4vmljq0f2apyqqyzds9968p42l4n";
      })
      {
        system = prev.stdenv.hostPlatform.system;
        config = prev.config;
      };
in
{
  terraria-server =
    assert
      terrariaCommit.terraria-server.version == "1.4.5.0"
      || throw ''
        terraria-server version mismatch.
        This overlay pins terraria-server to 1.4.5.0 from nixpkgs master.
        If release-25.11 now provides this version or newer,
        you can safely remove overlays/terraria-server-1.4.5.0-master-412d8dd.nix
      '';
    terrariaCommit.terraria-server;
}
