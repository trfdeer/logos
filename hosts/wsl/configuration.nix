{
  pkgs,
  config,
  inputs,
  hostname,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  wsl.enable = true;
  wsl.defaultUser = id.username;

  networking.hostName = hostname;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  users.users.${id.username} = {
    isNormalUser = true;
    description = id.fullName;
    extraGroups = [ "wheel" ];
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
  programs.nix-ld.enable = true;

  system.stateVersion = config.sqwer.platform.stateVersion;
}
