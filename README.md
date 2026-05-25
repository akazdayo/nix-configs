# NixOS / Darwin Configuration

Nix flake monorepo for NixOS, server, and macOS hosts with Home Manager.

## Quick Start

```bash
# Apply NixOS desktop
nh os switch

# Apply NixOS server
nh os switch --hostname server

# Apply macOS
nix run nix-darwin -- switch --flake .#macbook

# Check flake integrity
nix flake check

# Update dependencies
nix flake update
```

## Hosts

| Host      | Platform                | Command                                          |
| --------- | ----------------------- | ------------------------------------------------ |
| `nixos`   | NixOS (x86_64-linux)    | `nh os switch`                                   |
| `server`  | NixOS (x86_64-linux)    | `nh os switch --hostname server`                 |
| `macbook` | Darwin (aarch64-darwin) | `nix run nix-darwin -- switch --flake .#macbook` |

## Infrastructure

`infra/openstack/` — OpenTofu IaC
