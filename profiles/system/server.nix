{ lib, pkgs, ... }: {
  documentation.enable = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;

  # Headless trims
  boot.bcache.enable = false;
  programs.nano.enable = false;
  xdg.sounds.enable = false;
  xdg.mime.enable = false;
  fonts.fontconfig.enable = false;
  documentation.man.enable = false;

  # Image builds happen off-host
  logos.system.docker.package = lib.mkDefault (pkgs.docker.override { buildxSupport = false; });

  # Rebuilds run on the workstation (`just upgrade`) and copy closures to the
  # target; the target never resolves flakes, so don't pin nixpkgs (~197 MiB)
  # and keep no channels.
  nixpkgs.flake.setFlakeRegistry = false;
  nixpkgs.flake.setNixPath = false;
  nix.channel.enable = false;

  # Installer tools are useless on an already-deployed machine;
  # nixos-rebuild and nixos-version stay for remote upgrades.
  system.tools.nixos-build-vms.enable = false;
  system.tools.nixos-enter.enable = false;
  system.tools.nixos-generate-config.enable = false;
  system.tools.nixos-install.enable = false;
  system.tools.nixos-option.enable = false;

  # Perlless NixOS: etc-overlay and userborn replace the perl-based
  # activation paths; the build fails if any perl store path appears.
  system.etc.overlay.enable = lib.mkDefault true;
  services.userborn.enable = lib.mkDefault true;
  documentation.info.enable = lib.mkDefault false;
  system.forbiddenDependenciesRegexes = [ "perl" ];
}
