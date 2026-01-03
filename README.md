# NixOS / Home Manager Configuration

This repository contains a structured NixOS + Home Manager configuration designed for:

* Single- or multi-host systems
* Reusable profiles
* Clear separation between identity, platform, OS behavior, and home behavior

The layout is intentionally opinionated and optimized for long-term maintainability.

---

## Repository Structure

```sh
.
├── flake.nix
├── hosts/
│   ├── <hostname>/
│   │   ├── configuration.nix
│   │   ├── home-configuration.nix
│   │   └── ...
│   └── <hostname>/
│       └── ...
│
├── modules/
│   ├── commonModules/      # Option schemas & namespaces (sqwer.*)
│   ├── nixosModules/       # Low-level OS / infra features
│   └── homeModules/        # Reusable Home Manager features
│
├── profiles/
│   ├── identities/         # One file per human identity
│   ├── platform.nix        # Lifecycle invariants (stateVersion, etc.)
│   ├── nixosProfiles/      # Shared OS behavior (base system)
│   └── homeProfiles/       # Home Manager behavior bundles
│
```

---

## Design Principles

* Modules define capabilities, never values
* Profiles compose behavior, not hosts
* Hosts decide placement, nothing else

---

## Initial Installation (First Boot)

On first installation, use the following commandL

```sh
sudo nixos-rebuild --flake . boot
```

After the build completes, set a password for the primary user defined in the selected identity **before rebooting**.

From the installer or live environment, enter the installed system and set the password:

```sh
nixos-enter
passwd <username>
```

After setting the password, reboot the system:

```sh
sudo reboot
```

---

## Required Manual Steps (Post-Install)

Some steps cannot (or should not) be automated.

### Samba User Password

If Samba is enabled on the host, you must manually create the Samba user password:

```sh
smbpasswd -a $USER
```

Without this, the Samba share will exist but authentication will fail.

---

### Secure Boot Key Enrollment (Lanzaboote)

After the first successful boot, while the system is still in Secure Boot setup mode, enroll the keys:

```sh
nix run "nixpkgs#sbctl" -- enroll-keys -m
```

This only needs to be done once per machine.

After enrolling the keys, reboot the system:

```sh
sudo reboot
```

Then enroll the TPM2 key for the encrypted root (replace `<encrypted partition>` accordingly):

```sh
systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7+8+12 <encrypted partition>
```

Reboot once more after enrollment:

```sh
sudo reboot
```

**Note:** Only perform Secure Boot key enrollment and TPM2 enrollment on machines where Secure Boot is enabled. Do not run these steps on systems without Secure Boot support or where it is intentionally disabled.

---

## Home Manager Notes

* Home Manager users are created centrally in `profiles/nixosProfiles/base.nix`
* Host-specific Home Manager tweaks live in `hosts/<hostname>/home-configuration.nix`
* Do not redefine `home = { ... }` in host HM files — always set sub-options

---

## Standalone Home Manager (Non-NixOS Systems)

This repository also supports standalone Home Manager usage on non-NixOS systems (e.g. Arch Linux).

### Important: Nix daemon trust model

On non-NixOS systems, Nix is typically installed as a multi-user daemon.
In this mode:

* Home Manager only writes client-side configuration
* Certain Nix settings are restricted and ignored unless the user is trusted

If using the standalone Home Manager configuration and enabling nix.settings, you must add the user to the Nix daemon’s trusted users list.

Edit /etc/nix/nix.conf as root:

```nix
trusted-users = root <username>
```

Then restart the Nix daemon:

```sh
sudo systemctl restart nix-daemon
```

Without this step, the daemon will ignore restricted settings such as:

* `auto-optimise-store`
* `use-xdg-base-directories`

This requirement does not apply on NixOS, where the system configuration owns the Nix daemon.

---

## Notes for Future Maintenance

* `system.stateVersion` and `home.stateVersion` are sourced from `profiles/platform.nix`
* Identity files are one per user
* Avoid importing host paths from profiles except via controlled mechanisms
* If something feels duplicated, it likely belongs higher in the hierarchy

---

## Status

This repository is considered structurally complete.
Future changes should primarily involve adding hosts or extending profiles — not restructuring the core.
