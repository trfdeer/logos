{
  lib,
  pkgs,
  isDesktop,
  modules,
  profiles,
  config,
  hostname,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  sqwer.platform = {
    isNixosSystem = true;
    hostName = hostname;
  };

  # ------------------------------------------------------------
  # Locale / time (system-wide defaults)
  # ------------------------------------------------------------
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  # ------------------------------------------------------------
  # Primary user
  # ------------------------------------------------------------
  users.users.${id.username} = {
    isNormalUser = true;
    description = id.fullName;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = id.sshPublicKeys;
    initialHashedPassword = lib.mkForce id.hashedPassword;
  };

  # ------------------------------------------------------------
  # Home Manager
  # ------------------------------------------------------------
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      modules.common
      { sqwer.platform = config.sqwer.platform; }
    ];

    users.${id.username}.imports = [
      modules.home
      profiles.home.base
    ]
    ++ lib.optionals isDesktop [
      profiles.home.desktop
    ];
  };

  # ------------------------------------------------------------
  # Nix / nixpkgs policy
  # ------------------------------------------------------------
  nix.settings = {
    use-xdg-base-directories = true;
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ id.username ];
  };

  # ------------------------------------------------------------
  # Common programs
  # ------------------------------------------------------------
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  sqwer.system = {
    ssh.enable = lib.mkDefault true;
  }
  // lib.optionalAttrs (config.sqwer.platform.isDesktop) {
    _1password = {
      enable = true;
      systemUsers = [ id.username ];
    };
  };

  # ------------------------------------------------------------
  # Lifecycle
  # ------------------------------------------------------------
  system.stateVersion = config.sqwer.platform.stateVersion;

  boot.zfs.forceImportRoot = lib.mkForce false;
  environment.defaultPackages = [ ];
}
