# ============================================================
# DO NOT APPLY
#
# Historical one-time disko configuration used to provision
# the vault disk. This disk contains persistent data and must
# never be reformatted.
#
# Kept for reference only.
# ============================================================
{
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
}
