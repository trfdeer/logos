{
  constants,
  pkgs,
  inputs,
  sqwer,
  hostname,
  ...
}:
{
  wsl.enable = true;
  wsl.defaultUser = constants.username;

  networking.hostName = hostname;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  users.users.${constants.username} = {
    isNormalUser = true;
    description = constants.name;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = constants.sshKeys;
  };

  home-manager = {
    extraSpecialArgs = { inherit constants; };
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${constants.username}.imports = [
      sqwer.homeModules
      inputs.catppuccin.homeModules.catppuccin
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
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  system.stateVersion = constants.stateVersion;
}
