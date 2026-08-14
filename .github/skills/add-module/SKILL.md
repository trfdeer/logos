---
name: add-module
description: "Use when: adding a new reusable module under modules/ in the logos flake. Covers option naming, aggregator registration, and profile wiring."
---

# Add a new module

Use this skill when adding reusable NixOS or Home Manager configuration under `modules/`.

## Decision tree

- Shared between NixOS and Home Manager? → `modules/common/<name>.nix` and import in `modules/common/default.nix`.
- NixOS only? → `modules/system/<category>/<name>.nix` and import in `modules/system/default.nix`.
- Home Manager only? → `modules/home/<category>/<name>.nix` and import in `modules/home/default.nix`.

## Module template

```nix
{ lib, config, pkgs, ... }:
let
  cfg = config.sqwer.<subsystem>.<name>;
in
{
  options.sqwer.<subsystem>.<name> = {
    enable = lib.mkEnableOption "<description>";
  };

  config = lib.mkIf cfg.enable {
    # your configuration here
  };
}
```

Replace `<subsystem>` with `system` or `home`. Use `options.sqwer.*` for project-specific toggles.

## Wiring it in

1. Add the file in the appropriate `modules/` subtree.
2. Import it in the nearest `default.nix`.
3. Enable it by default in a profile (e.g. `profiles/system/base.nix`) or expose it as a host-level toggle.

## Validation

- Run `nix fmt`.
- Run `nix build ".#nixosConfigurations.<host>.config.system.build.toplevel"` for an affected host.
- Check that the option namespace is consistent with nearby modules.
