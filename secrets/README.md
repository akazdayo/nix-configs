# Secrets

Encrypted files in this directory are managed with sops and consumed by sops-nix. Keep every tracked encrypted file at its current path unless a dedicated secret migration explicitly requires otherwise.

## Recipients

Host SSH public keys can be converted to age recipients with:

```bash
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```

The YubiKey recipient and per-host creation rules are defined in `.sops.yaml`. Private host keys remain on their hosts; sops-nix reads `/etc/ssh/ssh_host_ed25519_key` for unattended decryption.

## Inventory

| Path                                      | Consumer                                 |
| ----------------------------------------- | ---------------------------------------- |
| `secrets/common/wireguard.yaml`           | `modules/nixos/networking/wireguard.nix` |
| `secrets/milk/wakatime.yaml`              | `modules/nixos/wakatime.nix`             |
| `secrets/hinata/attic.yaml`               | `modules/nixos/containers/attic.nix`     |
| `secrets/hinata/cloudflared.yaml`         | `modules/nixos/cloudflared.nix`          |
| `secrets/hinata/litellm.yaml`             | `modules/nixos/litellm.nix`              |
| `secrets/hinata/litellm-chatgpt.yaml`     | `modules/nixos/litellm.nix`              |
| `secrets/openstack/gateway/velocity.yaml` | Gateway and Minecraft server modules     |

`home/programs/secrets.nix` configures Home Manager's sops/age tooling. Chiffon currently has a reserved creation rule but no tracked encrypted secret.

## Editing

Edit an existing file in place:

```bash
sops secrets/milk/wakatime.yaml
```

After intentionally adding a recipient, update existing metadata in place:

```bash
sops updatekeys secrets/milk/wakatime.yaml
```

Do not decrypt encrypted YAML during ordinary repository work, and never commit plaintext credentials.

## Legacy host-local secrets

These Hinata container inputs intentionally remain outside sops-nix:

- `/etc/nextcloud-adminpass`, mounted into Nextcloud as `/run/secrets/nextcloud-adminpass`
- `/etc/searx-env`, mounted into SearXNG as `/run/secrets/searx-env`

Do not move or migrate them without an explicit task.
