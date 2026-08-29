# AI Agent Instructions — `logos`

This repository is a NixOS / Home Manager flake for managing multiple machines (`hosts/`).

## Quick orientation

- **[flake.nix](flake.nix)** declares inputs and delegates to **[outputs/default.nix](outputs/default.nix)**.
- **[utils/makeSystem.nix](utils/makeSystem.nix)** and **[utils/makeHome.nix](utils/makeHome.nix)** assemble every configuration.
- **[hosts/](hosts/)** — one directory per machine; each has `configuration.nix` and usually `home-configuration.nix`.
- **[modules/](modules/)** — reusable `sqwer.*` options and implementations (`common/`, `home/`, `system/`).
- **[profiles/](profiles/)** — composed selections of modules (`system/`, `home/`, `hardware/`, `storage-layouts/`).
- **[secrets/](secrets/)** — SOPS-encrypted JSON files.
- **[just/](just/)** — Just recipes for secrets, building images, and remote upgrades.

## Conventions

- Use the custom `sqwer.*` option namespace for project-specific configuration.
  - `sqwer.platform.*` — host metadata: `hostName`, `roles`, `stateVersion`, `isWsl`, `isNixosSystem`.
  - `sqwer.identity.*` — derived from decrypted secrets: `username`, `fullName`, `hashedPassword`, `git`, `sshPublicKeys`, `sshHosts`.
  - `sqwer.secrets.*` — parsed raw JSON from `.runtime/secrets/`.
  - `sqwer.system.*` — NixOS-only options.
  - `sqwer.home.*` — Home Manager-only options.
- Module skeleton:

  ```nix
  { lib, config, ... }:
  let
    cfg = config.sqwer.<subsystem>.<name>;
  in
  {
    options.sqwer.<subsystem>.<name> = {
      enable = lib.mkEnableOption "...";
    };

    config = lib.mkIf cfg.enable {
      # implementation
    };
  }
  ```

- Profiles use `lib.mkDefault` for values hosts may override.
- Host `roles` are limited to `"desktop"`, `"server"`, `"dev"`.
  - `profiles/system/base.nix` maps roles to home profiles.
  - `makeSystem` imports `profiles.system.desktop` when `"desktop"` is in roles, and `profiles.system.server` when `"server"` is in roles.

## Commit & changelog conventions

### Commit messages (Conventional Commits)

Format: `type(scope): subject` — imperative mood, no trailing period.

Allowed types: `feat`, `fix`, `refactor`, `perf`, `build`, `ci`, `docs`, `style`, `chore`, `revert`.

Allowed scopes — **closed list, never invent one on the fly**:

| Scope      | Covers                                                            |
| ---------- | ----------------------------------------------------------------- |
| `flake`    | `flake.nix`, `flake.lock`, `outputs/`, `utils/`                   |
| `host`     | `hosts/` — machine-specific config; name the machine in subject   |
| `home`     | `modules/home/`                                                   |
| `system`   | `modules/system/`                                                 |
| `common`   | `modules/common/`                                                 |
| `profiles` | `profiles/`                                                       |
| `secrets`  | `secrets/` and the `just secrets` recipes                         |
| `build`    | image build recipes (`just/build` etc.)                           |
| `upgrade`  | remote upgrade recipes (`just upgrade`)                           |
| `ci`       | `.github/`                                                        |
| `docs`     | `AGENTS.md`, `README.md`, `docs/`                                 |

- Per-host scopes are never allowed (e.g. `sol`, `brim`) — use `host`.
- Change spanning multiple areas — omit the scope (`feat: ...`).
- Genuinely new top-level area — add a row to this table in the same commit that first uses it.

### Commit message bodies (Keep a Changelog)

Release tooling generates changelogs from commit message bodies, so do **not** maintain a manual `CHANGELOG` file.

Bodies use the [Keep a Changelog](https://keepachangelog.com/) section labels:

- Available labels: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. Use only the ones that apply, in that order.
- Each label is a heading line followed by `-` bullets, one per user-visible change.
- Default label for the commit type: `feat` → `Added`, `fix` → `Fixed`, `refactor` / `perf` / user-visible `chore` → `Changed`.
- Content-based labels win over the type default: deprecations → `Deprecated`, removals → `Removed`, security fixes → `Security`.
- `docs`, `style`, `ci`, `build` commits are usually body-less.

Example:

```text
feat(home): add opencode home module

Added:
- `sqwer.home.opencode` option managing OpenCode (package, settings, TUI)
- `oc` shell alias for opencode
```

## Common commands

Format the whole tree:

```bash
nix fmt
```

Build a host's NixOS closure:

```bash
nix build ".#nixosConfigurations.<host>.config.system.build.toplevel"
```

Build images (via Just):

```bash
just build iso <host>      # installer ISO
just build lxc <host>      # Proxmox LXC tarball
just build wsl <host>      # WSL tarball
just build image <host> <TYPE>  # generic system.build.TYPE
```

Remote deployment:

```bash
just upgrade os <flake-output> [<target-host>]
just upgrade home <flake-output> [<target-host>]
just upgrade install <flake-output> [<target-host>] [port]
```

If `<target-host>` is omitted, it defaults to the same value as `<flake-output>`.

## Secrets workflow

Encrypted files are under `secrets/`; do not edit them as plain JSON.

1. Decrypt locally: `just secrets init`
2. Edit: `just secrets edit secrets/<file>.json`
3. Remove plaintext: `just secrets clean`

`just secrets init` also sets `core.hooksPath` to `.githooks` and stages decrypted files with `git add -fN`. Never commit `.runtime/`.

> **NEVER read files under `secrets/` or `.runtime/` under any circumstances.** These files contain encrypted or plaintext secrets; they must not be inspected, summarized, copied, or transmitted by an AI agent. Use `just secrets edit` if the user needs to change secrets.

## Adding a new host

1. Create `hosts/<name>/configuration.nix` and `home-configuration.nix` if needed.
2. Register it in **[hosts/default.nix](hosts/default.nix)**.
3. Declare it in **[outputs/nixosConfigurations.nix](outputs/nixosConfigurations.nix)** and its standalone home config in **[outputs/homeConfigurations.nix](outputs/homeConfigurations.nix)**.
4. Add a `<name>` entry in `secrets/outConfig.json` so `sqwer.identity` resolves; re-encrypt with SOPS.
5. Import the appropriate hardware profile from `profiles/hardware/` and, if needed, a storage-layout profile from `profiles/storage-layouts/`.

## Adding a new module or profile

- New module: add under `modules/<area>/`, import it in the nearest `default.nix`, and follow the `sqwer.<subsystem>.<name>` option pattern.
- New profile: add under `profiles/system/` or `profiles/home/` and register it in the corresponding `default.nix`.
- New hardware/storage profile: add under `profiles/hardware/` or `profiles/storage-layouts/` and register it in the corresponding `default.nix`.

## Important pitfalls

- Never use `/tmp` for testing changes; use `.runtime/agent/` instead.
- A host **must** exist in `secrets/outConfig.json` or evaluation fails with an assertion in `modules/common/identity.nix`.
- `sqwer.system.boot.secureBoot.enable = true;` forces `boot.loader.systemd-boot` off via `lanzaboote`.
- Impermanence uses `preservation`, not `impermanence.nix`, preserving files on `/persistent/nixos`.
- Proxmox LXC hosts set `nix.settings.sandbox = false`.
- `outputs/homeConfigurations.nix` currently defines `"dwai@brim"` with `name = "zeph"` — verify host names match when adding homes.

## Validation

CI (`.github/workflows/nix.yml`) runs `nixfmt-tree --ci .` only. `nix flake check` and per-host evaluation are commented out, so run them locally before claiming a change is safe.
