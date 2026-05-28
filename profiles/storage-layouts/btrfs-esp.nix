{ name, device, ... }:
let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
  ];
in
{
  disko.devices.disk.${name} = {
    inherit device;
    type = "disk";

    content = {
      type = "gpt";

      partitions.ESP = {
        size = "512M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };

      partitions.root = {
        size = "100%";

        content.type = "btrfs";
        content.extraArgs = [
          "-f"
          "-L"
          "root"
        ];

        content.subvolumes."@root" = {
          mountpoint = "/";
          mountOptions = btrfsOpts;
        };

        content.subvolumes."@home" = {
          mountpoint = "/home";
          mountOptions = btrfsOpts;
        };

        content.subvolumes."@nix" = {
          mountpoint = "/nix";
          mountOptions = btrfsOpts;
        };

        content.subvolumes."@var" = {
          mountpoint = "/var";
          mountOptions = btrfsOpts;
        };

        content.subvolumes."@log" = {
          mountpoint = "/var/log";
          mountOptions = btrfsOpts;
        };

      };
    };
  };
}
