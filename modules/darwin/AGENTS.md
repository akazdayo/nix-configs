# modules/darwin

**Generated:** 2026-05-19 | **Commit:** 94337f6
Parent: [root AGENTS.md](../../AGENTS.md)

## OVERVIEW

Darwin (macOS) system modules — 13 domain directories mirrored from NixOS, mostly placeholders. Only `system/` and `networking/` have active config.

## STRUCTURE

```
modules/darwin/
├── audio/default.nix           # Placeholder
├── boot/default.nix            # Placeholder
├── containers/default.nix      # Placeholder
├── desktop/default.nix         # Placeholder
├── flatpak/default.nix         # Placeholder
├── gaming/default.nix          # Placeholder
├── hardware/default.nix        # Placeholder
├── locale/default.nix          # Placeholder
├── networking/default.nix      # Active: tailscale
├── system/default.nix          # Active: nix-command, flakes, allowUnfree
├── users/default.nix           # Placeholder
├── virtualization/default.nix  # Placeholder
└── default.nix                 # Placeholder entry point
```

## WHERE TO LOOK

| Task                       | Location                              | Notes                                     |
| -------------------------- | ------------------------------------- | ----------------------------------------- |
| Add Darwin system setting  | `modules/darwin/<domain>/default.nix` | Register in `profiles/darwin/desktop.nix` |
| Darwin-specific packages   | `home/packages/darwin.nix`            |                                           |
| Homebrew casks/brews       | `hosts/macbook/homebrew.nix`          |                                           |
| Host-local Darwin settings | `hosts/macbook/host-data.nix`         | Hybrid: both data + darwin system options |

## CONVENTIONS

- **`default.nix` naming**: Darwin modules use `default.nix` (single macOS variant), unlike NixOS modules which use `desktop.nix`/`server.nix` suffixes.
- **Module registration**: Add to `profiles/darwin/desktop.nix` — this profile imports directories (e.g., `../../modules/darwin/boot`), which resolves to `default.nix`.
- **Most modules are empty placeholders** — only add content when a real macOS-specific setting is needed. Do not create modules that simply mirror NixOS settings.
- **Darwin system options in host-data.nix**: Some darwin-level system settings (`nix.settings`, `system.stateVersion`, user config) live in `hosts/macbook/host-data.nix` alongside host-local data — this is a deviation from the NixOS pattern. New darwin settings may go either in `host-data.nix` or in `modules/darwin/<domain>/default.nix`.
- **`modules/shared/`** is the intended home for cross-platform modules safe to evaluate on both NixOS and Darwin. Currently empty.

## ANTI-PATTERNS

- Creating NixOS-specific options in Darwin modules — Darwin modules must evaluate cleanly on macOS.
- Filling placeholder modules with empty NixOS mirrors — only add content when a real macOS difference exists.
- Forgetting to register new modules in `profiles/darwin/desktop.nix`.

## NOTES

- Darwin uses `nix-darwin.lib.darwinSystem` (not `lib.nixosSystem`). The builder is `mkDarwinHost` in `flake.nix`.
- Home-manager is included via `home-manager.darwinModules.home-manager` (not `nixosModules.home-manager`).
- No lanzaboote or sops-nix at the system level for Darwin. sops-nix is available via HM (`inputs.sops-nix.homeManagerModules.default` in `home/profiles/darwin.nix`).
- `homebrew` is configured in `hosts/macbook/homebrew.nix` — a Darwin-only host file.
