{
  pkgs,
  inputs,
  config,
  ...
}:

let
  id = config.sqwer.identity;
in
{
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
  };

  # ------------------------------------------------------------
  # Home Manager
  # ------------------------------------------------------------
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      ../../modules/coreModules
      ../identities/primary.nix
      ../platform.nix
    ];

    users.${id.username}.imports = [
      inputs.catppuccin.homeModules.catppuccin
      ../../modules/homeModules
      ../homeProfiles/base.nix
    ];
  };

  # ------------------------------------------------------------
  # Nix / nixpkgs policy
  # ------------------------------------------------------------
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

  # ------------------------------------------------------------
  # Common programs
  # ------------------------------------------------------------
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # ------------------------------------------------------------
  # Lifecycle
  # ------------------------------------------------------------
  system.stateVersion = config.sqwer.platform.stateVersion;
}
