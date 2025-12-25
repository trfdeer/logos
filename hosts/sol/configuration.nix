{
  lib,
  constants,
  pkgs,
  inputs,
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

    initrd.luks.devices.vault = {
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b402b400e-part1";
      name = "vault-crypt";
      allowDiscards = true;
    };

    loader.systemd-boot = {
      enable = lib.mkForce false;
      consoleMode = "max";
      configurationLimit = 3;
    };

    lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      pkiBundle = "/etc/secureboot";
    };

    supportedFilesystems = [ "btrfs" ];
  };

  fileSystems."/vault" = {
    device = "/dev/mapper/vault";
    fsType = "btrfs";
    options = [
      "subvol=@vault"
      "ssd"
      "space_cache=v2"
      "compress=zstd"
      "noatime"
    ];
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
      inputs.catppuccin.homeModules.catppuccin
    ];
  };

  sqwer = {
    tailscale = {
      enable = true;
      operator = constants.username;
    };

    incus = {
      enable = false;
      adminUser = constants.username;
    };

    samba = {
      enable = true;
      shareName = "vault";
      shareUser = constants.username;
      sharePath = "/vault";
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
