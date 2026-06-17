# NixOS / Darwin Configuration

Nix flake monorepo for NixOS, server, and macOS hosts with Home Manager.

## Quick Start

```bash
# Apply NixOS desktop
nh os switch

# Apply NixOS server
nh os switch --hostname hinata

# Apply macOS
nix run nix-darwin -- switch --flake .#chiffon

# Check flake integrity
nix flake check

# Update dependencies
nix flake update
```

## Hosts

| Host      | Platform                | Command                                          |
| --------- | ----------------------- | ------------------------------------------------ |
| `milk`    | NixOS (x86_64-linux)    | `nh os switch`                                   |
| `hinata`  | NixOS (x86_64-linux)    | `nh os switch --hostname hinata`                 |
| `chiffon` | Darwin (aarch64-darwin) | `nix run nix-darwin -- switch --flake .#chiffon` |

## Infrastructure

`infra/openstack/` — OpenTofu IaC
