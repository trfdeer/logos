{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.system.libvirtd;
in
{
  options.sqwer.system.libvirtd = {
    enable = lib.mkEnableOption "Enable libvirtd";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = ''
        List of users to be added to `libvirt`, `kvm`, and `qemu` group.
      '';
    };

    nestedVirt.enable = lib.mkEnableOption "Enable Nested Virtualization support";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    }
    // lib.optionalAttrs (config.sqwer.system.cockpit.enable) {
      dbus.enable = true;
    };
    virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages =
      with pkgs;
      [ OVMF ] ++ lib.optional config.sqwer.system.cockpit.enable pkgs.virt-manager;

    users.extraGroups.kvm.members = cfg.users;
    users.extraGroups.qemu.members = cfg.users;
    users.extraGroups.libvirtd.members = cfg.users;

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
  };
}
