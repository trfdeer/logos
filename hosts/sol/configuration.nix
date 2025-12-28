{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
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

    # Run `nix run nixpkgs#sbctl -- enroll-keys -m` after first boot while in setup mode.
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
  users.users.${id.username} = {
    isNormalUser = true;
    description = id.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = id.sshPublicKeys;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      ../../modules/coreModules
      ../../profiles/primary/identity.nix
    ];

    users.${id.username}.imports = [
      inputs.catppuccin.homeModules.catppuccin

      ../../modules/homeModules
      ../../profiles/primary/home.nix
      ./home-configuration.nix
    ];
  };

  sqwer = {
    tailscale = {
      enable = true;
      operator = id.username;
      advertiseRoutes = "172.16.10.0/24";
    };

    # Run `smbpasswd -a $USER` after installing
    samba = {
      enable = true;
      name = "vault";
      path = "/vault";
      owner = id.username;
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
    trusted-users = [ id.username ];
  };

  programs.zsh.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;

  system.stateVersion = config.sqwer.platform.stateVersion;
}
