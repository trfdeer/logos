{ ... }:
{
  sqwer.identity = {
    fullName = "Tuhin Tarafder";
    username = "ttarafder";
    email = "ttarafder7d1@protonmail.com";
    sshPublicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBod7BQCA2N5GCdkD8NJzjhx5uajVrUwNCok+EYtDAvA"
    ];
    gitSshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNyNZFAlLgqaLZGIB79Gz/FT0rj9PcIYW6zaM4fhUhb";
    sshHosts = {
      gh = {
        domain = "github.com";
        user = "git";
        sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNyNZFAlLgqaLZGIB79Gz/FT0rj9PcIYW6zaM4fhUhb";
      };
      gh-uni = {
        domain = "github.com";
        user = "git";
        sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFVwygedJ6Ykrhrd/OJ/uBEkYoMYDXBoUf2jJyvwuTLG";
      };
    };
  };
}
