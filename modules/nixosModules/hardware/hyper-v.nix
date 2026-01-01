{ lib, config, ... }:
let
  cfg = config.sqwer.hardware.hyperv;
in
{
  options.sqwer.hardware.hyperv = {
    enable = lib.mkEnableOption "Enable Hyper-V specific patches";
  };

  # based on https://github.com/NixOS/nixos-hardware/blob/40b1a28dce561bea34858287fbb23052c3ee63fe/microsoft/hyper-v/README.md
  config = lib.mkIf cfg.enable {
    # REQUIRED - see: https://github.com/nixos/nixpkgs/issues/9899
    boot.initrd.kernelModules = [
      "hv_vmbus"
      "hv_storvsc"
    ];

    # RECOMMENDED
    # - use 800x600 resolution for text console, to make it easy to fit on screen
    boot.kernelParams = [ "video=hyperv_fb:800x600" ]; # https://askubuntu.com/a/399960
    # - avoid a problem with `nix-env -i` running out of memory
    boot.kernel.sysctl."vm.overcommit_memory" = "1"; # https://github.com/NixOS/nix/issues/421

    boot.initrd.checkJournalingFS = false;
  };
}
