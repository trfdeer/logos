{ lib, ... }: {
  sqwer.home = {
    tmux.enable = lib.mkDefault true;
    nix.enable = lib.mkDefault false;
    ssh.enable = lib.mkDefault false;
  };
}
