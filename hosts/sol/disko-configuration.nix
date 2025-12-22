{
  disko.devices = {
    disk.vault = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b402b400e";
      content = {
        type = "gpt";
        partitions.vault = {
          size = "100%";
          content = {
            type = "luks";
            name = "vault-crypt";
            settings = {
              allowDiscards = true;
            };
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "vault"
              ];
              subvolumes = {
                "@vault" = {
                  mountpoint = "/vault";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@snapshots" = { };
              };
            };
          };
        };
      };
    };
  };
}
