# OpenStack NixOS Provisioning with OpenTofu

This module provisions a NixOS VM on OpenStack from qcow2 image `ac5fc61e-258b-4f8b-a06c-229c26f1e38f`. The NixOS image uses **amazon-init** (not cloud-init) to process userdata: a shell script is injected via config-drive and executed on first boot, which runs `nixos-rebuild switch` from `github:akazdayo/nix-configs`.

## Authentication

Authentication is intentionally sourced from the OpenStack provider environment, not from tracked files.

- Standard OpenStack environment variables:
  - `OS_AUTH_URL`
  - `OS_USERNAME`
  - `OS_PASSWORD`
  - `OS_PROJECT_NAME`
  - `OS_USER_DOMAIN_NAME`
  - `OS_PROJECT_DOMAIN_NAME`
  - `OS_REGION_NAME`
- Or use `OS_CLOUD` with a matching `clouds.yaml` entry.
- Application credentials are also supported:
  - `OS_APPLICATION_CREDENTIAL_ID`
  - `OS_APPLICATION_CREDENTIAL_SECRET`

Never commit credentials, tokens, passwords, `clouds.yaml` secrets, or populated auth files to tracked files in this repo.

## Required Inputs

| Variable | Type | Required | Description |
|---|---|---:|---|
| `instance_name` | `string` | Yes | Name for the OpenStack compute instance. |
| `host_name` | `string` | No, default `"openstack"` | NixOS flake host output name. |
| `config_ref` | `string` | No, default `"main"` | Git branch/tag/commit in `github:akazdayo/nix-configs`. |
| `image_id` | `string` | No, default `"ac5fc61e-258b-4f8b-a06c-229c26f1e38f"` | Glance image UUID. |
| `flavor_name` | `string` | Yes | OpenStack flavor name. |
| `network_name` | `string` | Yes | OpenStack network name. |
| `subnet_id` | `string` | No, optional | Subnet UUID for fixed IP. Leave empty to let OpenStack choose. |
| `keypair_name` | `string` | Yes | Existing OpenStack keypair name. Preferred because it avoids generating private keys in state. |
| `public_key_path` | `string` | No, optional | Path to SSH public key for new keypair creation. Use only if `keypair_name` is empty. |
| `ssh_allowed_cidrs` | `list(string)` | Yes | CIDR blocks allowed for SSH. Must be explicit and non-empty. Never use `0.0.0.0/0`. |
| `allocate_floating_ip` | `bool` | No, default `true` | Whether to allocate a floating IP. |
| `external_network_name` | `string` | Conditionally required | External network name for the floating IP pool. Required when `allocate_floating_ip = true`. |
| `metadata` | `map(string)` | No, optional | Instance metadata. |
| `tags` | `list(string)` | No, default `["nixos", "openstack"]` | Instance tags. |
| `ssh_user` | `string` | No, default `"akazdayo"` | Post-bootstrap SSH username. |

Example structure:

```hcl
instance_name         = "openstack-example"
host_name             = "openstack"
config_ref            = "main"
image_id              = "ac5fc61e-258b-4f8b-a06c-229c26f1e38f"
flavor_name           = "<OPENSTACK_FLAVOR_NAME>"
network_name          = "<OPENSTACK_NETWORK_NAME>"
subnet_id             = ""
keypair_name          = "<YOUR_KEYPAIR_NAME>"
public_key_path       = ""
ssh_allowed_cidrs     = ["<YOUR_IP>/32"]
allocate_floating_ip  = true
external_network_name = "<EXTERNAL_NETWORK_NAME>"

metadata = {
  environment = "example"
}

tags     = ["nixos", "openstack"]
ssh_user = "akazdayo"
```

## Local State Warning

⚠️ OpenTofu state (`*.tfstate`, `*.tfstate.*`) and variable files (`*.tfvars`) are gitignored. Keep them secure. The lock file (`.terraform.lock.hcl`) **is tracked**.

## `config_ref` Guidance

The `config_ref` variable specifies which Git branch, tag, or commit of `github:akazdayo/nix-configs` contains the `openstack` host output. Before provisioning:

1. Ensure the `hosts/openstack/` directory and `nixosConfigurations.openstack` exist in the flake at that ref.
2. Use a branch name during development, then pin to a tag or commit for stability.

## Quick Start

```bash
# 1. Copy and fill in your values
cp terraform.tfvars.example terraform.tfvars
# Edit: set flavor_name, network_name, keypair_name, ssh_allowed_cidrs, external_network_name

# 2. Set OpenStack auth
source openrc.sh  # or set OS_* env vars, or export OS_CLOUD=mycloud

# 3. Enter the Nix dev shell (provides opentofu)
nix develop

# 4. Initialize
tofu -chdir=infra/openstack init

# 5. Plan (review changes before applying)
tofu -chdir=infra/openstack plan -var-file=terraform.tfvars

# 6. Apply
tofu -chdir=infra/openstack apply -var-file=terraform.tfvars

# 7. Get SSH host
tofu -chdir=infra/openstack output ssh_host

# 8. SSH into the VM
ssh akazdayo@$(tofu -chdir=infra/openstack output -raw ssh_host)
```

If you run the copy command from the repository root instead of inside `infra/openstack`, use:

```bash
cp infra/openstack/terraform.tfvars.example infra/openstack/terraform.tfvars
```

## Offline Validation

No OpenStack credentials are required for basic local validation:

```bash
nix develop -c tofu -chdir=infra/openstack fmt -check
nix develop -c tofu -chdir=infra/openstack init -backend=false
nix develop -c tofu -chdir=infra/openstack validate -var-file=terraform.tfvars.example
```

## Debugging Bootstrap

First boot uses **amazon-init** (NixOS's built-in init for EC2/OpenStack, **not** cloud-init). Amazon-init executes the shell script injected via config-drive. The script logs everything to `/var/log/nixos-bootstrap.log`. Successful completion creates `/var/lib/nixos-bootstrap/success`.

**Note: on first boot, OpenStack keypair injection goes to `root`, not the configured user.** Use `ssh root@<ip>` for initial access; after `nixos-rebuild switch` succeeds, the NixOS user configuration takes over.

```bash
# Quick status: did bootstrap succeed?
ssh root@$(tofu -chdir=infra/openstack output -raw ssh_host) \
  'sudo test -f /var/lib/nixos-bootstrap/success && echo SUCCESS || echo FAILED'

# Read the bootstrap log
ssh root@$(tofu -chdir=infra/openstack output -raw ssh_host) \
  'sudo tail -200 /var/log/nixos-bootstrap.log'

# Check amazon-init status (run on the VM)
sudo systemctl status amazon-init
sudo journalctl -u amazon-init --no-pager -n 50

# After bootstrap, SSH as your configured user
ssh akazdayo@$(tofu -chdir=infra/openstack output -raw ssh_host) \
  'test -e /run/current-system && echo "NixOS: OK"'
```

### Manual Bootstrap (if userdata didn't run)

If amazon-init failed and the script wasn't executed at all:

```bash
# SSH as root and run the rebuild manually
ssh root@$(tofu -chdir=infra/openstack output -raw ssh_host)
mkdir -p /etc/nix
echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
nixos-rebuild switch --flake github:akazdayo/nix-configs/main#openstack
```

## Instance Recreation Warning

Changing these values destroys and recreates the instance, so treat the VM as ephemeral and assume all local data on it will be lost:

- `user_data` changes
- `config_drive`
- `image_id`
- `key_pair` / `keypair_name`
- `network` / port changes
- `block_device` (not used currently)

Changing `flavor_name` triggers a resize instead of recreation, which may require cloud admin confirmation.

## Security Notes

- SSH keypair: always prefer an existing `keypair_name`; generated private keys would be stored in state.
- SSH CIDR: never use `0.0.0.0/0`; restrict access to your actual IP range.
- State files: `*.tfstate` and `*.tfvars` are gitignored but not encrypted locally.
- No passwords, tokens, or API keys belong in tracked files.
