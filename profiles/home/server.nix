{ lib, ... }: {
  sqwer.home = {
    tmux.enable = lib.mkDefault true;
    nix.enable = lib.mkDefault false;
    ssh.enable = lib.mkDefault false;
    neovim.enable = false;
  };

  # Headless: no manual pages, no font/mime machinery, no sensors tooling
  programs.man.enable = false;
  fonts.fontconfig.enable = false;
  xdg.mime.enable = lib.mkForce false;
  sqwer.home.utils.sensors = false;

  sqwer.home.helix.enable = lib.mkDefault true;

  # Helix with only the grammars a server needs
  sqwer.home.helix.grammars = [
    "bash"
    "ini"
    "json"
    "markdown"
    "markdown-inline"
    "nix"
    "query"
    "toml"
    "yaml"
  ];
}
