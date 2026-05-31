{
  lib,
  name,
  device,
  disableCow ? false,
  ...
}:
let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
  ]
  ++ (lib.optional disableCow [ "nodatacow" ]);

  partlabel = "${name}-root";
in
{
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = [
      "size=25%"
      "mode=755"
    ];
  };

  disko.devices.disk.${name} = {
    inherit device;
    type = "disk";

    content.type = "gpt";
    content.partitions.boot = {
      name = "boot";
      size = "1G";
      type = "EF02";

      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };
    content.partitions.persistent = {
      size = "100%";

      content = {
        type = "luks";
        name = "${partlabel}-crypt";

        settings = {
          allowDiscards = true;
          crypttabExtraOpts = [ "tpm2-measure-pcr=yes" ];
        };

        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            partlabel
          ];
          subvolumes = {
            "@persistent" = {
              mountpoint = "/persistent";
              mountOptions = btrfsOpts ++ [ "subvol=persistent" ];
            };
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = btrfsOpts ++ [ "subvol=nix" ];
            };
          };
        };
      };
    };
  };
}
