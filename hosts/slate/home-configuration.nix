{ ... }:
{
  sqwer.home.sshcfg = {
    enable = true;
    hosts = {
      gh = {
        domain = "github.com";
        user = "git";
        sshPubKey = "REDACTED_SSH_KEY";
      };
      gh-uni = {
        domain = "github.com";
        user = "git";
        sshPubKey = "REDACTED_SSH_KEY";
      };
    };
  };
}
