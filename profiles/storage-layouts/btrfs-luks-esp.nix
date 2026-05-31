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
  disko.devices.disk.${name} = {
    inherit device;
    type = "disk";

    content = {
      type = "gpt";
      partitions = {
        esp = {
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
            name = "${partlabel}-root";

            settings = {
              allowDiscards = true;
              crypttabExtraOpts = [
                "tpm2-device=auto"
                "tpm2-measure-pcr=yes"
              ];
            };

            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                partlabel
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
