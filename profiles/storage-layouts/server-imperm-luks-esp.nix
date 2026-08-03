{
  lib,
  name,
  device,
  disableCow ? false,
  ...
}:
let
  btrfsOpts = [
    "compress=zstd:3"
    "noatime"
    "ssd"
    "space_cache=v2"
    "discard=async"
  ]
  ++ lib.optional disableCow "nodatacow";

  partlabel = "${name}-persistent";
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

    content = {
      type = "gpt";

      partitions = {
        boot = {
          name = "boot";
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        persistent = {
          size = "100%";

          content = {
            type = "luks";
            name = "${partlabel}-crypt";

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
                "@persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = btrfsOpts ++ [ "subvol=persistent" ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOpts ++ [ "subvol=nix" ];
                };

                "@containers" = {
                  mountpoint = "/var/lib/containers";
                  mountOptions = btrfsOpts ++ [
                    "subvol=containers"
                    "autodefrag"
                  ];
                };

                "@libvirt" = {
                  mountpoint = "/var/lib/libvirt";
                  mountOptions = btrfsOpts ++ [
                    "subvol=libvirt"
                  ];
                };

                "@vm-images" = {
                  mountpoint = "/var/lib/libvirt/images";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "ssd"
                    "space_cache=v2"
                    "discard=async"
                    "subvol=vm-images"
                    "nodatacow"
                  ];
                };

                "@machines" = {
                  mountpoint = "/var/lib/machines";
                  mountOptions = btrfsOpts ++ [
                    "subvol=machines"
                  ];
                };

                "@srv" = {
                  mountpoint = "/srv";
                  mountOptions = btrfsOpts ++ [
                    "subvol=srv"
                  ];
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = btrfsOpts ++ [
                    "subvol=log"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persistent".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
}
