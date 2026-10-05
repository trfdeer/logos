{ pkgs, ... }:
{
  # btop-rocm removed — GPU stats now need the rocm-smi stack (see host
  # configuration.nix); run `btop` with GPU support in a container instead
}
