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
    ./disko-configuration.nix
  ];

  boot = {
    bootspec.enable = true;
    initrd.systemd.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot = {
      enable = lib.mkForce false;
      consoleMode = "max";
      configurationLimit = 3;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    supportedFilesystems = [ "btrfs" ];
  };

  networking.hostName = "sol";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${constants.username} = {
    isNormalUser = true;
    description = constants.name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = constants.sshKeys;
  };

  home-manager = {
    extraSpecialArgs = { inherit constants; };
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${constants.username}.imports = [
      ../../modules/home-manager
      ./home-configuration.nix
    ];
  };

  sqwer = {
    tailscale = {
      enable = true;
      operator = constants.username;
    };

    incus = {
      enable = true;
      adminUser = constants.username;
    };
  };

  # Configure nix / nixpkgs
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    use-xdg-base-directories = true;
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  programs.zsh.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;

  system.stateVersion = constants.stateVersion;
}
