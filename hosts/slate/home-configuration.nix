{ ... }:
{
  sqwer.home.sshcfg = {
    enable = true;
    hosts = {
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
