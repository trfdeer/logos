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
    type = "disk";
    device = "/dev/disk/by-id/nvme-nvme.1c5c-202020435941354e303137393132323035413230-4243373131204e564d6520534b2068796e6978203531324742-00000001";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            foramt = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
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
    };
  };
}
