{ lib, ... }: {
  documentation.enable = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
}
