# logos

A NixOS and Home Manager flake for declaratively managing multiple machines.

## Repository layout

| Directory | Purpose |
| --------- | ------- |
| [flake.nix](flake.nix) | Flake inputs, including nixpkgs, home-manager, lanzaboote, disko, and sqpkgs. |
| [hosts/](hosts/) | One directory per machine, containing `configuration.nix` and usually `home-configuration.nix`. |
| [modules/](modules/) | Reusable configuration modules using the `sqwer.*` option namespace. |
| [profiles/](profiles/) | Composed selections of modules for system, home, hardware, and storage layouts. |
| [utils/](utils/) | Helpers for assembling system and home configurations. |
| [outputs/](outputs/) | Flake outputs for dev shells, formatters, home configurations, and NixOS configurations. |
| [secrets/](secrets/) | SOPS-encrypted JSON files consumed by the configuration. |
| [just/](just/) | Just recipes for secrets management, image builds, and remote upgrades. |

## Build and deploy

Format the repository:

```bash
nix fmt
```

Build a host's NixOS closure:

```bash
nix build ".#nixosConfigurations.<host>.config.system.build.toplevel"
```

Build images:

```bash
just build iso <host>                  # installer ISO
just build lxc <host>                  # Proxmox LXC tarball
just build wsl <host>                  # WSL tarball
just build image <host> <TYPE>         # generic system.build.TYPE
```

Deploy remotely:

```bash
just upgrade os <target-host> <flake-output>
just upgrade home <target-host> "dwai@<host>"
just upgrade install <flake-output> <target-host> [port]
```

## Conventions

- Project-specific configuration lives under the `sqwer.*` option namespace.
  - `sqwer.platform.*` — host metadata: `hostName`, `roles`, `stateVersion`, `isWsl`, `isNixosSystem`.
  - `sqwer.identity.*` — derived from decrypted secrets: `username`, `fullName`, `hashedPassword`, `git`, `sshPublicKeys`, `sshHosts`.
  - `sqwer.secrets.*` — parsed raw JSON from `secrets/decrypted/`.
  - `sqwer.system.*` — NixOS-only options.
  - `sqwer.home.*` — Home Manager-only options.
- Modules follow the standard `mkEnableOption` / `mkIf cfg.enable` pattern.
- Profiles use `lib.mkDefault` for values hosts may override.
- Host `roles` are limited to `"desktop"`, `"server"`, and `"dev"`.
  - `profiles/system/base.nix` maps roles to home profiles.
  - `makeSystem` imports `profiles.system.desktop` when `"desktop"` is in roles, and `profiles.system.server` when `"server"` is in roles.

## Secrets workflow

Encrypted files are tracked under `secrets/`. Do not edit them as plain JSON.

```bash
just secrets init                      # decrypt and configure git hooks
just secrets edit secrets/<file>.json  # edit an encrypted file
just secrets clean                     # remove plaintext files
```

`just secrets init` also sets `core.hooksPath` to `.githooks` and stages decrypted files with `git add -fN`. Do not commit `secrets/decrypted/`.

## Adding a host

1. Create `hosts/<name>/configuration.nix` and `home-configuration.nix` if needed.
2. Register it in [hosts/default.nix](hosts/default.nix).
3. Declare it in [outputs/nixosConfigurations.nix](outputs/nixosConfigurations.nix) and its standalone home config in [outputs/homeConfigurations.nix](outputs/homeConfigurations.nix).
4. Add a `<name>` entry in `secrets/outConfig.json` so `sqwer.identity` resolves, then re-encrypt.
5. Import the appropriate hardware profile from [profiles/hardware/](profiles/hardware/) and, if needed, a storage-layout profile from [profiles/storage-layouts/](profiles/storage-layouts/).

## Adding a module or profile

- New module: add under `modules/<area>/`, import it in the nearest `default.nix`, and follow the `sqwer.<subsystem>.<name>` option pattern.
- New profile: add under `profiles/system/` or `profiles/home/` and register it in the corresponding `default.nix`.
- New hardware/storage profile: add under `profiles/hardware/` or `profiles/storage-layouts/` and register it in the corresponding `default.nix`.

## Important notes

- A host must exist in `secrets/outConfig.json` or evaluation fails with an assertion in [modules/common/identity.nix](modules/common/identity.nix).
- Enabling `sqwer.system.boot.secureBoot.enable` disables `boot.loader.systemd-boot` via lanzaboote.
  - Secure Boot must be enabled and be in Setup Mode in firmware before booting the installer.
  - After installation, enroll the LUKS TPM2 key by running:

    ```bash
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=2+7+12 <LUKS-DEVICE>
    ```

- Impermanence uses the `preservation` project, preserving files on `/persistent/nixos`.
- Proxmox LXC hosts set `nix.settings.sandbox = false`.

## Validation

CI runs `nixfmt-tree --ci .` only. Run `nix flake check` and per-host evaluation locally before submitting changes.
