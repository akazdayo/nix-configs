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
sops secrets/nixos/home.yaml
```

Example content:

```yaml
immich-api-key: your-actual-api-key-here
```

Save and exit - sops will encrypt automatically.

## Current sops Boundary

`.sops.yaml` currently defines creation rules for five encrypted secret roots:

- `secrets/nixos/` - NixOS host-specific secrets encrypted to the `nixos` host key
- `secrets/server/` - server host-specific secrets encrypted to the `server` host key
- `secrets/attic/` - attic host-specific secrets encrypted to the `attic` host key (master key only until host is provisioned)
- `secrets/common/` - shared secrets encrypted to both Linux host keys
- `secrets/darwin/` - macOS host-specific secrets encrypted to the Darwin host key

Tracked encrypted secret files must stay at these paths so pure evaluation can still read them from the flake source.

### Current secret inventory

- `secrets/nixos/home.yaml`
  - Contains: `immich-api-key`
  - Status: encrypted with sops; do not decrypt in normal repo work
  - Used by: `modules/nixos/secrets/desktop.nix`
  - Host scope: the `nixos` desktop system profile
- `secrets/attic/atticd-env.yaml`
  - Contains: `atticd-env` (placeholder until provisioned)
  - Status: encrypted with sops to master key only
  - Used by: `modules/nixos/secrets/attic.nix`
  - Host scope: the `attic` OpenStack host
- `secrets/server/`, `secrets/common/`, `secrets/darwin/`
  - Current tracked state: placeholder `.gitkeep` only, no encrypted secret files committed today

### System-level vs Home Manager boundary

- System-level secrets live under `modules/nixos/secrets/` and are consumed by NixOS modules.
  - `modules/nixos/secrets/desktop.nix` currently declares `sops.secrets.immich-api-key` from `secrets/nixos/home.yaml`.
  - `modules/nixos/secrets/server.nix` currently only configures the server host age/SSH integration and does not declare any `sops.secrets.*` entries yet.
- Home Manager secret wiring lives in `home/programs/secrets.nix`.
  - This module is imported by the desktop, server, and Darwin Home Manager profiles.
  - It currently configures sops/age tooling only and does not declare any active Home Manager secrets yet.

### Current host usage

- `nixos` host
  - Imports `profiles/nixos/desktop.nix` -> `modules/nixos/secrets/desktop.nix`
  - Uses `secrets/nixos/home.yaml`
- `server` host
  - Imports `profiles/nixos/server.nix` -> `modules/nixos/secrets/server.nix`
  - Currently has no tracked sops-managed encrypted file in `secrets/server/`
- `attic` host
  - Imports `profiles/nixos/openstack/attic/default.nix` -> `modules/nixos/secrets/attic.nix`
  - Uses `secrets/attic/atticd-env.yaml` (re-encrypt to attic host key after provisioning)
- `macbook` host
  - Imports `home/programs/secrets.nix` through the Darwin Home Manager profile
  - `.sops.yaml` reserves `secrets/darwin/` for future Darwin secrets, but no encrypted file is committed there today

### Legacy non-sops container secret paths to preserve

These server container inputs are intentionally still host-local `/etc/...` files and are **not** managed by sops-nix during this refactor:

- `/etc/nextcloud-adminpass` -> bind-mounted into the Nextcloud container as `/run/secrets/nextcloud-adminpass`
- `/etc/searx-env` -> bind-mounted into the SearXNG container as `/run/secrets/searx-env`

Preserve these paths as-is for now; do not migrate, rename, or rekey them as part of repo structure work.

## Replacing the Current Desktop Secret

`secrets/nixos/home.yaml` currently contains the encrypted `immich-api-key` consumed by the desktop system module. Recreate it in place with your real secret if needed:

```bash
rm secrets/nixos/home.yaml
sops secrets/nixos/home.yaml
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
3. Rebuild: `sudo nixos-rebuild switch --flake .#nixos`

## Rotating Keys

After adding a new recipient to `.sops.yaml`, run `sops updatekeys` only for encrypted files that already exist at their current paths. For example:

```bash
sops updatekeys secrets/nixos/home.yaml
```

Do not run key rotation or move encrypted files during the repo structure refactor unless that is the explicit task.
