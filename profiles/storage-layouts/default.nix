{
  makeStorageLayout =
    {
      name,
      device,
      filesystem,
      encrypted ? { },
      passwordFile ? null,
      impermanent ? false,
      bootSize ? "1G",
      subvolumes ? [ ],
    }:
    { lib, ... }:
    let
      encryption = {
        enable = true;
        method = "tpm";
      }
      // (if builtins.isAttrs encrypted then encrypted else { enable = encrypted; });

      helpers = import ./lib.nix {
        inherit
          lib
          name
          device
          filesystem
          impermanent
          bootSize
          subvolumes
          ;

        encrypted = encryption.enable;
        inherit (encryption) method;
        inherit passwordFile;
      };

      diskDefinition = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = helpers.bootPartition;
            root = {
              size = "100%";
              content = helpers.rootContent;
            };
          };
        };
      };
    in
    {
      assertions = [
        {
          assertion = filesystem == "btrfs" || subvolumes == [ ];
          message = "makeStorageLayout: subvolumes must be empty when filesystem is not btrfs";
        }
        {
          assertion =
            !encryption.enable
            || lib.elem encryption.method [
              "tpm"
              "ssh"
            ];
          message = "makeStorageLayout: encrypted.method must be \"tpm\" or \"ssh\"";
        }
      ];

      disko.devices = {
        disk.${name} = diskDefinition;
      }
      // lib.optionalAttrs impermanent {
        nodev = {
          "/" = helpers.mkTmpfsRoot { };
        }
        // lib.optionalAttrs (filesystem != "btrfs") {
          # XFS has no subvolumes: the store lives in a directory on the
          # persistent filesystem and is bind-mounted at /nix.
          "/nix" = lib.mkMerge [
            helpers.nixBind
            ({ rootMountPoint, ... }: {
              preMountHook = ''mkdir -p "${rootMountPoint}/persistent/nix"'';
            })
          ];
        };
      };

      fileSystems = lib.mkIf impermanent {
        "/persistent".neededForBoot = true;
      };
    };

  btrfsSubvols =
    let
      defaultOpts = [
        "compress=zstd"
        "noatime"
        "ssd"
        "space_cache=v2"
        "discard=async"
      ];
      subvol = name: mountpoint: options: {
        inherit name mountpoint options;
      };
    in
    {
      root = [
        (subvol "@root" "/" defaultOpts)
        (subvol "@home" "/home" defaultOpts)
        (subvol "@nix" "/nix" defaultOpts)
        (subvol "@var" "/var" defaultOpts)
        (subvol "@log" "/var/log" defaultOpts)
      ];

      impermanent = [
        (subvol "@persistent" "/persistent" defaultOpts)
        (subvol "@nix" "/nix" defaultOpts)
      ];

      impermanentServer = [
        (subvol "@persistent" "/persistent" defaultOpts)
        (subvol "@nix" "/nix" defaultOpts)
        (subvol "@containers" "/var/lib/containers" (defaultOpts ++ [ "autodefrag" ]))
        (subvol "@libvirt" "/var/lib/libvirt" defaultOpts)
        (subvol "@vm-images" "/var/lib/libvirt/images" (defaultOpts ++ [ "nodatacow" ]))
        (subvol "@machines" "/var/lib/machines" defaultOpts)
        (subvol "@srv" "/srv" defaultOpts)
        (subvol "@log" "/var/log" defaultOpts)
      ];
    };
}
