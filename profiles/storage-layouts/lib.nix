{
  lib,
  name,
  device,
  filesystem,
  encrypted,
  method ? "tpm",
  passwordFile ? null,
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

  mkLuks =
    content:
    {
      type = "luks";
      name = "${partLabel}-crypt";
      settings = luksSettings;
      inherit content;
    }
    // lib.optionalAttrs (passwordFile != null) {
      inherit passwordFile;
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
      # XFS labels are limited to 12 characters; keep the tail so labels
      # differing in suffix (persistent vs root) stay unique.
      extraArgs = [
        "-L"
        (builtins.substring (builtins.stringLength label - 12) 12 label)
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

  # XFS has no subvolumes, so the store lives in a directory on the
  # persistent filesystem and is bind-mounted at /nix.
  nixBind = {
    type = "nodev";
    fsType = "xfs"; # mount -o bind ignores the type, but disko requires one
    device = "/persistent/nix";
    mountpoint = "/nix";
    mountOptions = [
      "bind"
      "noatime"
    ];
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
    nixBind
    baseBtrfsOpts
    mkBtrfsSubvolume
    mkBtrfsFilesystem
    mkXfsFilesystem
    rootFilesystem
    rootContent
    bootPartition
    ;
}
