{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.system.boot;
in
{
  options.sqwer.system.boot = {
    doNotConfigure = lib.mkEnableOption "Skip configuring boot options";

    kernelPackage = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs.linuxPackages_latest;
    };

    secureBoot = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Enable Secure Boot";
        };
      };
    };
  };

  config = lib.mkIf (!cfg.doNotConfigure) (
    lib.mkMerge [
      {
        boot = {
          bootspec.enable = true;
          initrd.systemd.enable = true;
          kernelPackages = cfg.kernelPackage;
          loader.timeout = 10;

          loader = {
            systemd-boot = {
              enable = true;
              consoleMode = "max";
              configurationLimit = 3;
            };
            efi.canTouchEfiVariables = true;
          };

          supportedFilesystems = [ "btrfs" ];
        };
      }
      # luks.devices.vault = {
      #   device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b402b400e-part1";
      #   name = "vault-crypt";
      #   allowDiscards = true;
      # };
      (lib.mkIf cfg.secureBoot.enable {
        boot = {
          loader.systemd-boot.enable = lib.mkForce false;

          lanzaboote = {
            enable = true;
            autoGenerateKeys.enable = true;
            autoEnrollKeys = {
              enable = true;
              autoReboot = true;
            };
            pkiBundle = "/var/lib/sbctl/pki";
          };
        };
      })
    ]
  );
}
