{
  lib,
  constants,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Configure bootloader
  boot.bootspec.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
    consoleMode = "max";
    configurationLimit = 3;
  };

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "sol";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${constants.username} = {
    isNormalUser = true;
    description = constants.name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = constants.sshKeys;
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = { inherit constants; };
    users.${constants.username}.imports = [
      ../../modules/home-manager
      ./home-configuration.nix
    ];
  };

  sqwer.tailscale = {
    enable = true;
    operator = constants.username;
  };

  # Configure nix / nixpkgs
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.zsh.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "25.11";

}
