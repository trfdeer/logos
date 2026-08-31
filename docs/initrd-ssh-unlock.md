# Initrd SSH Remote LUKS Unlock

Remote LUKS unlock over SSH from the initrd, so a machine with an encrypted
root volume can be booted remotely without a console and without the passphrase
being stored anywhere on disk. Intended for headless servers/VPS instances.

## How it works

- The initrd network is brought up (DHCP or static), an `sshd` runs inside the
  initrd, and on connect it runs `systemd-cryptsetup attach` on each
  `boot.initrd.luks.devices` via a `ForceCommand`. No shell is exposed; the
  `-tt` flag is required to allocate the TTY the passphrase prompt needs.
- The unlock command is a `&&`-chain across all LUKS devices, each invoked as
  `systemd-cryptsetup attach <name> <device>` (only devices with a non-null
  `device` attribute are included).
- Optionally, Tailscale runs inside the initrd so the unlock SSH is reachable
  only over the tailnet, avoiding an exposed public port. When disabled (or
  when `publicFallback` is on), sshd listens on all interfaces.
- The encryption method is chosen per storage layout: `encrypted.method = "tpm"`
  (default, TPM-based auto-unlock) or `"ssh"` (passphrase unlock over initrd
  SSH). TPM crypttab options are only applied for the `tpm` method.

## Configuring a host

There are two layers:

1. The storage layout must mark the encrypted volume as SSH-unlocked.
2. `sqwer.system.boot.initrdSsh` must be enabled and tuned.

### 1. Storage layout (makeStorageLayout)

In `hosts/<name>/configuration.nix`, set the `encrypted` argument to an attrs
with `method = "ssh"`. This skips the `tpm2-device=auto` /
`tpm2-measure-pcr=yes` crypttab options, so the volume requires a passphrase
instead of auto-unlocking via TPM.

```nix
(profiles.storage-layouts.makeStorageLayout {
  name = "nixos";
  device = "/dev/vda";
  filesystem = "xfs";
  encrypted = {
    method = "ssh";
  };
  impermanent = true;
})
```

All other hosts (beet, brim, sol, zeph) use the TPM default via `encrypted = { };`.

### 2. Initrd SSH module

Enable `sqwer.system.boot.initrdSsh`. The module sets `boot.initrd.enable`,
enables initrd networking and initrd sshd, and configures
`boot.initrd.systemd` with the network + (optionally) the tailscale units.

```nix
sqwer.system.boot.initrdSsh = {
  enable = true;
  port = 22;
  hostKey = "/persistent/nixos/etc/ssh/initrd_host_ed25519_key";
  publicFallback = false;

  network = hostCfg.network;          # from sqwer.secrets.outConfig

  tailscale = {
    enable = true;
    stateDir = "/persistent/nixos/var/lib/tailscale-initrd";
    ip = hostCfg.initrdSsh.bindIp;
  };
};
```

Options (all under `sqwer.system.boot.initrdSsh`):

| Option | Default | Purpose |
| ------ | ------- | ------- |
| `enable` | — | Enable initrd SSH LUKS unlock. |
| `port` | `22` | Port for the initrd sshd. |
| `hostKey` | `/etc/ssh/initrd_host_ed25519_key` | sshd `HostKey` in the initrd; also appended via `boot.initrd.secrets`. Generated during activation if missing. On impermanence hosts point it into the preserved tree. |
| `authorizedKeys` | `id.sshPublicKeys` | Authorized keys for root in the initrd sshd. |
| `interface` | network interface or `en*` | Interface glob matched by the initrd `00-initrd-ssh` networkd unit. |
| `publicFallback` | `true` | Listen on all interfaces. When `false` (and `tailscale.ip` is set) sshd binds only `127.0.0.1` + the tailnet address. |
| `network.mode` | `auto` | `auto` (DHCP) or `manual`. |
| `network.manualConfiguration` | `null` | `{ address, gateway, dns }` used when `mode = "manual"`. |
| `tailscale.enable` | — | Run Tailscale in the initrd. |
| `tailscale.stateDir` | `/var/lib/tailscale-initrd` | tailscaled state dir (node key). Appended to the initrd via `boot.initrd.secrets`; must be enrolled before rebuild. On impermanence hosts point into the preserved tree. |
| `tailscale.hostname` | `<hostName>-initrd` | Tailscale hostname announced by the initrd node. |
| `tailscale.ip` | `null` | Tailnet IPv4 of the initrd node; used to bind sshd when `publicFallback` is false. |

Assertions (evaluation fails if unmet):

- When `publicFallback = false`, `tailscale.ip` must be set.
- When `network.mode = "manual"`, `network.manualConfiguration` must be set.
- At least one `boot.initrd.luks.devices` entry with a non-null `device` must
  exist (i.e. the storage layout set `encrypted.method = "ssh"`).

A warning is emitted if `tailscale.enable` and `publicFallback` are both on
(the initrd sshd stays reachable on the public interface).

### Per-host secrets

The secrets schema (`modules/common/secrets.nix`) exposes per-host options,
read from `secrets/outConfig.json` (decrypted under `.runtime/secrets/`):

- `sqwer.secrets.outConfig.<host>.initrdSsh.bindIp` — tailnet IP the initrd
  sshd binds to (used as `tailscale.ip`).
- `sqwer.secrets.outConfig.<host>.network` — the initrd network config
  (reused as `initrdSsh.network`; same `networkConfigType` submodule as the
  main network: `mode` + `manualConfiguration`).

Add these values for the host and re-encrypt with SOPS (see the repo's
`just secrets` workflow; edit with `just secrets edit secrets/outConfig.json`).

## Reference host: `star`

`hosts/star/configuration.nix` is the only current user of SSH LUKS unlock:

- A VPS server (`profiles.hardware.vm.vps01`), XFS root on `/dev/vda`,
  `encrypted.method = "ssh"`, impermanent, with the `/nix` bind mount on
  `/persistent/nix`.
- `sqwer.system.boot.initrdSsh` enabled with `port = 22`, host key at
  `/persistent/nixos/etc/ssh/initrd_host_ed25519_key`, `publicFallback = false`,
  static initrd network from secrets, and initrd Tailscale with
  `stateDir = /persistent/nixos/var/lib/tailscale-initrd` and
  `ip = hostCfg.initrdSsh.bindIp`.
- Registered in `hosts/default.nix` and `outputs/nixosConfigurations.nix`
  (roles: `server`).

## Steps

### Before the first unlock

1. Configure the host as above (storage layout + initrd SSH module + secrets).
2. Rebuild so the initrd host key is generated during activation:
   `nixos-rebuild switch`. The activation script `initrdSshHostKey` creates the
   key at `hostKey` if missing (it also `mkdir -p`s the tailscale `stateDir`
   when tailscale is enabled).
3. On impermanence hosts the host key is preserved via
   `preservation.preserveAt."/persistent/nixos"` (symlinked when the key lives
   outside `/persistent`).

### Enroll the initrd Tailscale identity (once)

The initrd node is a separate tailnet identity. Enroll it on the running system,
then rebuild so the state is baked into the initrd:

```bash
mkdir -p <stateDir>
tailscaled --statedir=<stateDir> \
  --socket=/run/tailscale-initrd-setup.sock \
  --tun=userspace-networking &
tailscale --socket=/run/tailscale-initrd-setup.sock up \
  --auth-key=<key> --hostname=<hostname>
tailscale --socket=/run/tailscale-initrd-setup.sock ip -4
kill %tailscaled
```

- Record the printed IPv4 in `sqwer.secrets.outConfig.<host>.initrdSsh.bindIp`.
- Rebuild.
- Once reachable only over the tailnet, set `publicFallback = false` to close
  the public unlock port (if not already set).

The initrd tailscale is started by the `tailscale-initrd.service` (after
`systemd-networkd.service` and `initrd-nixos-copy-secrets.service`), which runs
`tailscaled --statedir=<stateDir> --socket=/run/tailscale-initrd.sock`. The
`initrd-ssh-up.service` (after tailscale, before `sshd.service`) then runs
`tailscale up --hostname=<hostname>` and waits until the node has a tailnet IP
before sshd starts.

For `star` the concrete enrollment command would be:

```bash
mkdir -p /persistent/nixos/var/lib/tailscale-initrd
tailscaled --statedir=/persistent/nixos/var/lib/tailscale-initrd \
  --socket=/run/tailscale-initrd-setup.sock \
  --tun=userspace-networking &
tailscale --socket=/run/tailscale-initrd-setup.sock up \
  --auth-key=<key> --hostname=star-initrd
tailscale --socket=/run/tailscale-initrd-setup.sock ip -4
kill %tailscaled
```

Record the printed IPv4 as `sqwer.secrets.outConfig.star.initrdSsh.bindIp`
(and `sqwer.system.boot.initrdSsh.tailscale.ip`), then rebuild.

### Unlocking at boot

```bash
ssh -tt -p <port> root@<initrd-ssh-target>
```

The LUKS unlock runs automatically (`ForceCommand`); enter the passphrase at
the prompt. The `-tt` flag is required because the prompt needs a TTY.

For `star` the unlock command is:

```bash
ssh -tt -p 22 root@star-initrd
```

Enter the LUKS passphrase at the prompt (bound only to the tailnet address
since `publicFallback = false`).

### Deploying / rebuilding the host

Use the repo's Just recipes (see AGENTS.md) to build and push configs. For
`star` (VPS server, NixOS flake output `nixosConfigurations.star`):

```bash
just build image star <TYPE>          # build an image if needed
just upgrade os star star             # push and switch the NixOS config
```

`just upgrade os <flake-output> [<target-host>]`; here both default to `star`.
A reboot will then require the remote unlock above.

## Notes / pitfalls

- Do not read files under `secrets/` or `.runtime/` directly — use
  `just secrets edit` to change `outConfig.json` and re-encrypt.
- `nix.settings.sandbox` is set to `false` on Proxmox LXC hosts; irrelevant for
  initrd SSH but worth knowing when applying the same module to an LXC host.
- Changing `encrypted.method` from `tpm` to `ssh` removes the TPM crypttab
  options; a storage layout currently only carries one method at a time.
- When tailscale is enabled, `boot.initrd.systemd.storePaths` includes
  `tailscale`, `tailscaled`, the `initrd-ssh-up` script, and always
  `systemd-cryptsetup`; the `tun` kernel module is added to the initrd.
