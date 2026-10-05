{ lib, ... }: {
  # Headless VPS: no GPU userspace (mesa/llvm) even though the QEMU
  # virtual GPU is detected by facter
  hardware.graphics.enable = lib.mkForce false;

  hardware.facter.reportPath = ../../../.runtime/facter/vps01.json;
}
