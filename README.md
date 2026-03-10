# logos

NixOS + Home Manager configuration.

## Hosts

| Host | Role | Notes |
|------|------|-------|
| `rock` | Laptop | Dell Precision 3561, LUKS-encrypted root, Secure Boot (Lanzaboote) |
| `sol` | Desktop | SS Fury, LUKS-encrypted root + separate vault partition, Samba share, Tailscale exit node |
| `atlas` | VM | QEMU/Proxmox guest, static IP `172.16.11.102`, Docker, Tailscale |
| `rift` | LXC container | Proxmox LXC, Terraria + Minecraft servers |

---

## Initial Installation

```bash
sudo nixos-rebuild --flake .#<hostname> boot
```

Before rebooting, set the user password:

```bash
nixos-enter
passwd <username>
exit
sudo reboot
```

---

## Post-Install Steps

### Identity file

The identity file is not tracked in the repo. Generate it from the template before building:

```bash
# fill in profiles/identities/primary.nix from the template
```

### Secure Boot — `rock`, `sol`

These hosts use Lanzaboote. Key generation and enrollment happen automatically on first boot if the firmware is in Setup Mode. After the first successful boot:

```bash
nix run "nixpkgs#sbctl" -- enroll-keys -m
nix run "nixpkgs#sbctl" -- verify
```

Then enroll the TPM2 key for the encrypted root (replace `<partition>` with the LUKS partition, e.g. `/dev/nvme0n1p1`):

```bash
systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7+8+12 <partition>
sudo reboot
```

### Samba — `sol`

The Samba user password is not managed by NixOS and must be set manually:

```bash
smbpasswd -a <username>
```

The share is restricted to `100.64.0.0/10` (Tailscale range) and localhost. Access is authenticated — no guest access.

---

## Development

A devshell is available via `nix develop` (or automatically with `direnv`).

A pre-commit hook is installed under `.githooks/` — set it up with:

```bash
git config core.hooksPath .githooks
```
