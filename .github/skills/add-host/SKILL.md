---
name: add-host
description: "Use when: adding a new NixOS host to the logos flake. Walks through host directory, registration, output declaration, secrets entry, hardware/storage profile selection, and validation."
---

# Add a new NixOS host

Use this skill when the user wants to add a new machine to the `logos` flake.

## Prerequisites

- Know the desired hostname.
- Know whether it is a desktop, server, dev box, WSL, LXC, or installer target.
- Know the hardware profile to import (`profiles/hardware/devices/<device>` or `profiles/hardware/ct/proxmox-lxc` or `profiles/hardware/vm/<vm>`).
- Know the storage/disks so you can pick or parameterize a `profiles/storage-layouts/` profile.

## Steps

1. **Create host files**
   - `hosts/<name>/configuration.nix`
   - `hosts/<name>/home-configuration.nix` (only if home-manager deltas are needed)

2. **Register the host**
   - Add `<name> = ./<name>/configuration.nix;` to [hosts/default.nix](hosts/default.nix).

3. **Declare the system output**
   - Add an entry to [outputs/nixosConfigurations.nix](outputs/nixosConfigurations.nix) using `makeSystem`.
   - Set `prefs.roles` to the appropriate subset of `[ "desktop" "server" "dev" ]`.
   - Set `prefs.isWsl = true;` or `prefs.isLxc = true;` when applicable.

4. **Declare the standalone home output**
   - Add `"dwai@<name>" = makeHome { name = "<name>"; ... };` to [outputs/homeConfigurations.nix](outputs/homeConfigurations.nix).
   - Make sure the `name` argument matches the host, not a different host.

5. **Add the secrets entry**
   - Run `just secrets init` to decrypt.
   - Add a `<name>` entry in `secrets/decrypted/outConfig.json` that references a user from `identities.json`.
   - Re-encrypt with `just secrets edit secrets/outConfig.json`.
   - Run `just secrets clean` when done.

6. **Import hardware and storage profiles**
   - Import the right `profiles.hardware.*` module in `hosts/<name>/configuration.nix`.
   - Import a storage-layout profile if disk configuration is required, passing `device` from `config.sqwer.secrets.devices.*.drive_paths.root`.

7. **Configure services**
   - Use `sqwer.system.*` options for NixOS services (network, tailscale, docker, ssh, etc.).
   - Use `sqwer.home.*` options for Home Manager settings.

8. **Validate**
   - Run `nix fmt`.
   - Run `nix build ".#nixosConfigurations.<name>.config.system.build.toplevel"`.
   - If applicable, build an image with `just build lxc <name>` or `just build iso <name>`.

## Common mistakes

- Forgetting the `outConfig.json` entry causes an assertion failure in `modules/common/identity.nix`.
- Passing the wrong `name` to `makeHome` (see existing `"dwai@brim"` bug in `outputs/homeConfigurations.nix`).
- Committing `secrets/decrypted/`; they are staged with `git add -fN` but must remain untracked.
