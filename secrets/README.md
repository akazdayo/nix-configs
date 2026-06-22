# Secrets

This directory contains secrets encrypted with [sops](https://github.com/getsops/sops) and managed by [sops-nix](https://github.com/Mic92/sops-nix).

## Setup

### 1. Generate YubiKey age key

```bash
age-plugin-yubikey --generate --slot 1 --touch-policy always --name "primary"
```

### 2. Get your YubiKey recipient (public key)

```bash
age-plugin-yubikey --list-all
```

Copy the `age1yubikey1...` string and replace `age1replace-with-your-yubikey-recipient` in `.sops.yaml`.

### 3. Get host SSH-derived age recipients

On each host, run:

```bash
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```

Replace the placeholders in `.sops.yaml` with the actual values.

### 4. Host SSH key setup

This configuration uses SSH host keys for secret decryption (no YubiKey required for unattended boot).

On each host, the SSH host public key is converted to an age recipient:

```bash
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```

Add this output to `.sops.yaml` under the appropriate host key.

No private key files need to be copied - sops-install-secrets reads `/etc/ssh/ssh_host_ed25519_key` directly.

### 5. Create encrypted secrets

```bash
sops secrets/milk/home.yaml
```

Example content:

```yaml
immich-api-key: your-actual-api-key-here
```

Save and exit - sops will encrypt automatically.

## Current sops Boundary

`.sops.yaml` defines creation rules for four encrypted secret roots, aligned with the new host names:

- `secrets/milk/` - NixOS host-specific secrets encrypted to the `milk` host key
- `secrets/hinata/` - hinata host-specific secrets encrypted to the `hinata` host key
- `secrets/common/` - shared secrets encrypted to both Linux host keys
- `secrets/chiffon/` - macOS host-specific secrets encrypted to the `milk` host key

Tracked encrypted secret files must stay at these paths so pure evaluation can still read them from the flake source.

### Current secret inventory

- `secrets/milk/home.yaml`
  - Contains: `immich-api-key`
  - Status: encrypted with sops; do not decrypt in normal repo work
  - Used by: `modules/nixos/secrets/desktop.nix`
  - Host scope: the `milk` desktop system profile
- `secrets/hinata/cache.yaml`
  - Contains: `niks3-api-token`, `niks3-signing-key`, `rustfs-access-key`, `rustfs-secret-key`
  - Status: encrypted with sops; do not decrypt in normal repo work
  - Used by: `modules/nixos/cache/niks3.nix` and `modules/nixos/cache/rustfs.nix`
  - Host scope: the `hinata` server system profile
- `secrets/common/`, `secrets/chiffon/`
  - Current tracked state: placeholder `.gitkeep` only, no encrypted secret files committed today

### System-level vs Home Manager boundary

- System-level secrets live under `modules/nixos/secrets/` and are consumed by NixOS modules.
  - `modules/nixos/secrets/desktop.nix` currently declares `sops.secrets.immich-api-key` from `secrets/milk/home.yaml`.
  - `modules/nixos/secrets/server.nix` configures the hinata host age/SSH integration.
  - Cache service secrets (`niks3-api-token`, `niks3-signing-key`, `rustfs-access-key`, `rustfs-secret-key`) are declared in `modules/nixos/cache/niks3.nix` and `modules/nixos/cache/rustfs.nix` from `secrets/hinata/cache.yaml`.
- Home Manager secret wiring lives in `home/programs/secrets.nix`.
  - This module is imported by the desktop, server, and Darwin Home Manager profiles.
  - It currently configures sops/age tooling only and does not declare any active Home Manager secrets yet.

### Current host usage

- `milk` host
  - Imports `profiles/nixos/desktop.nix` -> `modules/nixos/secrets/desktop.nix`
  - Uses `secrets/milk/home.yaml`
- `hinata` host
  - Imports `profiles/nixos/server.nix` -> `modules/nixos/secrets/server.nix`
  - Uses `secrets/hinata/cache.yaml` for the Niks3/RustFS binary cache services
- `chiffon` host
  - Imports `home/programs/secrets.nix` through the Darwin Home Manager profile
  - `.sops.yaml` reserves `secrets/chiffon/` for future Darwin secrets, but no encrypted file is committed there today

### Legacy non-sops container secret paths to preserve

These server container inputs are intentionally still host-local `/etc/...` files and are **not** managed by sops-nix during this refactor:

- `/etc/nextcloud-adminpass` -> bind-mounted into the Nextcloud container as `/run/secrets/nextcloud-adminpass`
- `/etc/searx-env` -> bind-mounted into the SearXNG container as `/run/secrets/searx-env`

Preserve these paths as-is for now; do not migrate, rename, or rekey them as part of repo structure work.

## Replacing the Current Desktop Secret

`secrets/milk/home.yaml` currently contains the encrypted `immich-api-key` consumed by the desktop system module. Recreate it in place with your real secret if needed:

```bash
rm secrets/milk/home.yaml
sops secrets/milk/home.yaml
# Add: immich-api-key: your-real-api-key
# Save and exit - sops will encrypt with the host SSH key
```

### Security Note

This configuration uses SSH host keys for decryption. Anyone with root access to the host (who can read `/etc/ssh/ssh_host_ed25519_key`) can decrypt these secrets. This is a trade-off for unattended boot support.

## Adding a New Secret

1. Define it in the appropriate module:
   - Home-manager secrets: `home/programs/secrets.nix`
   - System secrets: `modules/nixos/secrets/desktop.nix` or `modules/nixos/secrets/server.nix`
2. Add the secret value to the corresponding `.yaml` file via `sops <path>`
3. Rebuild: `sudo nixos-rebuild switch --flake .#milk`

## Rotating Keys

After adding a new recipient to `.sops.yaml`, run `sops updatekeys` only for encrypted files that already exist at their current paths. For example:

```bash
sops updatekeys secrets/milk/home.yaml
```

Run `sops updatekeys <path>` after moving existing encrypted files so their metadata matches the new directory paths.
