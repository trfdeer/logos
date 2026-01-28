{
  lib,
  pkgs,
  inputs,
  modules,
  profiles,
  config,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  sqwer.env.isNixosSystem = true;

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
      modules.commonModules
      profiles.identities.primary
      profiles.platform
    ];

    users.${id.username}.imports = [
      inputs.catppuccin.homeModules.catppuccin
      modules.homeModules.sqwerHome
      profiles.identities.primary
      profiles.home.base
    ];
  };

  # ------------------------------------------------------------
  # Nix / nixpkgs policy
  # ------------------------------------------------------------
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.sqpkgs.overlays.default
      (import "${inputs.self}/overlays/terraria-server-1.4.5.0-master-412d8dd.nix")
    ];
  };

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
  };

  # ------------------------------------------------------------
  # Lifecycle
  # ------------------------------------------------------------
  system.stateVersion = config.sqwer.platform.stateVersion;
}
