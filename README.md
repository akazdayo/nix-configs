# NixOS / Darwin Configuration

Host-centric Nix flake for NixOS, NixOS-WSL, nix-darwin, Home Manager, and OpenStack infrastructure.

## Hosts

| Host        | Platform / role            | Apply                                            |
| ----------- | -------------------------- | ------------------------------------------------ |
| `milk`      | NixOS desktop              | `nh os switch`                                   |
| `hinata`    | NixOS server               | `nh os switch --hostname hinata`                 |
| `milfy`     | NixOS-WSL                  | `sudo nixos-rebuild switch --flake .#milfy`      |
| `gateway`   | OpenStack gateway          | `nix run .#deploy-openstack -- gateway`          |
| `minecraft` | OpenStack Minecraft server | `nix run .#deploy-openstack -- minecraft`        |
| `chiffon`   | macOS desktop              | `nix run nix-darwin -- switch --flake .#chiffon` |

## Structure

```text
flake.nix              # inputs, generic host builders, deploy/tooling outputs
hosts/<name>/          # complete imports and host-local values
modules/nixos/         # function-oriented reusable NixOS modules
modules/darwin/        # active nix-darwin leaf modules
home/programs/         # Home Manager program modules
home/packages/         # Home Manager package groups
infra/openstack/       # OpenTofu infrastructure
secrets/               # encrypted sops files; paths are stable
dotfiles/              # static files managed by Home Manager
```

There is no profile or `host-data.nix` layer. `hosts/<name>/default.nix` directly imports every enabled module and supplies host-local values through `local.*` options. Modules are grouped by function, such as `networking/`, `hardware/`, `containers/`, `minecraft/`, and `nix/`; standalone features remain top-level files.

## Development

```bash
nix develop
nix fmt
nix flake check
nixos-rebuild dry-build --flake .#milk
```

OpenStack provisioning is documented in [`infra/openstack/README.md`](infra/openstack/README.md). Secret management is documented in [`secrets/README.md`](secrets/README.md).
