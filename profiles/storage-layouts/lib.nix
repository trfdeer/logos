{
  lib,
  name,
  device,
  filesystem,
  encrypted,
  method ? "tpm",
  impermanent,
  bootSize,
  subvolumes,
  ...
}:
let
  partLabel = if impermanent then "${name}-persistent" else "${name}-root";

  luksSettings = {
    allowDiscards = true;
  }
  // (lib.optionalAttrs (method == "tpm") {
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-measure-pcr=yes"
    ];
  });

  mkLuks = content: {
    type = "luks";
    name = "${partLabel}-crypt";
    settings = luksSettings;
    inherit content;
  };

  mkEfiPartition =
    {
      size ? "1G",
      mountpoint ? "/boot",
    }:
    {
      inherit size;
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        inherit mountpoint;
        mountOptions = [ "umask=0077" ];
      };
    };

  mkTmpfsRoot =
    {
      size ? "25%",
    }:
    {
      fsType = "tmpfs";
      mountOptions = [
        "size=${size}"
        "mode=755"
      ];
    };

  baseBtrfsOpts = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
    "discard=async"
  ];

  mkBtrfsSubvolume =
    {
      name,
      mountpoint,
      options ? baseBtrfsOpts,
    }:
    {
      ${name} = {
        inherit mountpoint;
        mountOptions = options;
      };
    };

  mkBtrfsFilesystem =
    {
      label,
      subvolList,
    }:
    {
      type = "btrfs";
      extraArgs = [
        "-f"
        "-L"
        label
      ];
      subvolumes = lib.mkMerge (map mkBtrfsSubvolume subvolList);
    };

  mkXfsFilesystem =
    {
      label,
      mountpoint ? "/persistent",
      mountOptions ? [
        "defaults"
        "noatime"
      ],
    }:
    {
      type = "filesystem";
      format = "xfs";
      inherit mountpoint mountOptions;
      extraArgs = [
        "-L"
        label
      ];
    };

  rootFilesystem =
    if filesystem == "btrfs" then
      mkBtrfsFilesystem {
        label = partLabel;
        subvolList = subvolumes;
      }
    else
      mkXfsFilesystem {
        label = partLabel;
        mountpoint = if impermanent then "/persistent" else "/";
      };

  rootContent = if encrypted then mkLuks rootFilesystem else rootFilesystem;

  bootPartition = mkEfiPartition { size = bootSize; };
in
{
  inherit
    luksSettings
    mkLuks
    mkEfiPartition
    mkTmpfsRoot
    baseBtrfsOpts
    mkBtrfsSubvolume
    mkBtrfsFilesystem
    mkXfsFilesystem
    rootFilesystem
    rootContent
    bootPartition
    ;
}
