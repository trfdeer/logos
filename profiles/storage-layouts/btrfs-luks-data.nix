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

  partlabel = "${name}-data";
in
{
  disko.devices.disk.${name} = {
    inherit device;
    type = "disk";

    content = {
      type = "gpt";
      partitions.data = {
        size = "100%";

        content = {
          type = "luks";
          name = "${partlabel}-crypt";

          settings.allowDiscards = true;

          content.type = "btrfs";
          content.extraArgs = [
            "-f"
            "-L"
            partlabel
          ];

          content.subvolumes."@data" = {
            mountpoint = "/mnt/data/${name}";
            mountOptions = btrfsOpts;
          };
        };
      };
    };
  };
}
