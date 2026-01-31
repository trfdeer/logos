{ device, ... }:
let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
  ];
in
{
  disko.devices.disk.main = {
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
        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "root"
          ];
          subvolumes = {
            "@root" = {
              mountpoint = "/";
              mountOptions = btrfsOpts;
            };
            "@home" = {
              mountpoint = "/home";
              mountOptions = btrfsOpts;
            };
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = btrfsOpts;
            };
            "@var" = {
              mountpoint = "/var";
              mountOptions = btrfsOpts;
            };
            "@log" = {
              mountpoint = "/var/log";
              mountOptions = btrfsOpts;
            };
          };
        };
      };

    };
  };
}
