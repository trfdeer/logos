let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Vi3000_Internal_PCIe_NVMe_M.2_SSD_1TB_493754484830002";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "root-crypt";
                settings = {
                  allowDiscards = true;
                };
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

      #      vault = {
      #        type = "disk";
      #        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b402b400e";
      #        content = {
      #          type = "gpt";
      #          partitions.vault = {
      #            size = "100%";
      #            content = {
      #              type = "luks";
      #              name = "vault-crypt";
      #              settings = {
      #                allowDiscards = true;
      #              };
      #              content = {
      #                type = "btrfs";
      #                extraArgs = [
      #                  "-L"
      #                  "vault"
      #                ];
      #                subvolumes = {
      #                  "@vault" = {
      #                    mountpoint = "/vault";
      #                    mountOptions = [
      #                      "compress=zstd"
      #                      "noatime"
      #                    ];
      #                  };
      #                  "@snapshots" = { };
      #                };
      #              };
      #            };
      #          };
      #        };
      #      };
    };
  };
}
