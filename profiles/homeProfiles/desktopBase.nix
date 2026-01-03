{ ... }:
{
  imports = [ ./base.nix ];

  sqwer.env = {
    has1Password = true;
    isDesktop = true;
  };
}
