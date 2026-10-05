{ lib, pkgs, ... }: {
  # Headless server: no GPU userspace on the host even though the GPU is
  # detected by facter (containers bring their own userspace)
  hardware.graphics.enable = lib.mkForce false;

  # No GPU modules in the initrd (no early KMS / passthrough needed)
  boot.initrd.kernelModules = lib.mkForce [ "dm_mod" ];

  # Headless: nothing pairs Bluetooth devices
  hardware.bluetooth.enable = lib.mkForce false;

  # Curated firmware: the monolithic linux-firmware is ~810 MiB, almost all
  # of it for hardware this box doesn't have (qcom/nvidia/mellanox/wifi/DVB).
  # Keep GPU + common wired-NIC firmware only. This flag must stay off or
  # all-firmware.nix re-adds the full bundle alongside the curated set.
  # NOTE: check `dmesg | grep -i firmware` on first boot for missing files.
  hardware.enableRedistributableFirmware = false;
  hardware.firmware = lib.mkForce [
    (pkgs.runCommand "zeph-firmware" { } ''
      mkdir -p $out/lib/firmware
      for d in amdgpu i915 rtl_nic e100 e1000 bnx2; do
        if [ -d "${pkgs.linux-firmware}/lib/firmware/$d" ]; then
          cp -r "${pkgs.linux-firmware}/lib/firmware/$d" $out/lib/firmware/
        fi
      done
    '')
  ];

  hardware.facter.reportPath = ../../../.runtime/facter/desktop-gre.json;
}
