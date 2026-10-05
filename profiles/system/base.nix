{
  lib,
  pkgs,
  roles,
  modules,
  profiles,
  config,
  hostname,
  ...
}:
let
  id = config.logos.identity;
in
{
  logos.platform = {
    isNixosSystem = true;
    hostName = hostname;
    roles = roles;
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
      { logos.platform = config.logos.platform; }
    ];

    users.${id.username}.imports = [
      modules.home
      profiles.home.base
    ]
    ++ lib.optional (lib.elem "desktop" roles) profiles.home.desktop
    ++ lib.optional (lib.elem "server" roles) profiles.home.server
    ++ lib.optional (lib.elem "dev" roles) profiles.home.dev;
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

  logos.system = {
    ssh.enable = lib.mkDefault true;
  }
  // lib.optionalAttrs (lib.elem "desktop" config.logos.platform.roles) {
    _1password = {
      enable = true;
      systemUsers = [ id.username ];
    };
  };

  # ------------------------------------------------------------
  # Lifecycle
  # ------------------------------------------------------------
  system.stateVersion = config.logos.platform.stateVersion;

  boot.zfs.forceImportRoot = lib.mkForce false;
  environment.defaultPackages = [ ];
}
