{ constants, pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = constants.username;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  users.users.${constants.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = constants.sshKeys;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    nixd
    tmux
    nixfmt-rfc-style
    direnv
  ];

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  services.openssh.enable = true;

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = constants.stateVersion;
}
