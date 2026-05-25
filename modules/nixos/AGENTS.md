# modules/nixos

**Generated:** 2026-05-19 | **Commit:** 94337f6
Parent: [root AGENTS.md](../../AGENTS.md)

## OVERVIEW

NixOS system modules — 14 domains, each with `desktop.nix` and/or `server.nix` host-type variants.

## STRUCTURE

```
modules/nixos/
├── audio/desktop.nix          # PipeWire audio stack
├── boot/{desktop,server}.nix  # Bootloader (lanzaboote on desktop, systemd-boot on server)
├── containers/{desktop,server,immich,attic,pihole-unbound,searxng,nextcloud}.nix
├── desktop/desktop.nix        # DE (niri compositor, Firefox, printing, Sunshine)
│   └── wayland/{login,niri,variable}.nix
├── flatpak/desktop.nix        # Flatpak support
├── gaming/{desktop,minecraft-server,steam,wivrn,slimevr,alvr}.nix
├── hardware/{desktop,server,kernel,nvidia,swap,mounts,tablet}.nix
├── locale/{desktop,server}.nix
├── networking/{desktop,server,tailscale,cloudflared,macvlan-shim}.nix
├── secrets/{desktop,server}.nix
├── system/{desktop,server,nix-core,nix-ld,nh,packages,1password}.nix
├── users/{desktop,server}.nix
└── virtualization/{desktop,server,docker}.nix
```

## WHERE TO LOOK

| Task                     | Location                                      | Notes                                      |
| ------------------------ | --------------------------------------------- | ------------------------------------------ |
| Add NixOS system setting | Create `modules/nixos/<domain>/<variant>.nix` | Register in `profiles/nixos/<profile>.nix` |
| Host-local values        | `hosts/<host>/host-data.nix`                  | Access via `hostMeta.hostData.<key>`       |
| New container service    | `modules/nixos/containers/<name>.nix`         | Follow existing container template         |
| Add kernel module        | `modules/nixos/hardware/kernel.nix`           | CachyOS kernel via `nix-cachyos-kernel`    |

## CONVENTIONS

- **Host-type suffix naming**: `desktop.nix` / `server.nix` per domain. Desktop-only domains have just `desktop.nix`. Server-only features use domain-specific names (e.g., `minecraft-server.nix`, `cloudflared.nix`).
- **`default.nix` is NOT used in subdirectories** — unlike `home/programs/`, NixOS module domains use descriptive names. The top-level `modules/nixos/default.nix` is a placeholder.
- **Profiles are the ONLY composition layer**: `profiles/nixos/desktop.nix` and `profiles/nixos/server.nix` are the sole files that know the full set of modules. Import new modules there, never in `hosts/<host>/default.nix`.
- **`hostMeta.hostData` is the universal data bus**: All host-local values flow through this — never hardcode IPs, paths, or keys in modules.
- **Modules are unconditionally declarative**: No `lib.mkIf`, `lib.mkMerge`, `lib.mkDefault`. Conditional selection is at the profile level (which profile is imported).
- **System-wide `system.stateVersion = "25.11"`** is set in profiles, not in individual modules.

## ANTI-PATTERNS

- Importing modules directly from `hosts/<host>/default.nix` — use profiles.
- Hardcoding host-local values (IPs, paths, keys) — use `hostMeta.hostData`.
- Adding `lib.mkIf` conditionals in leaf modules — push conditional logic to profile selection.
- Modifying `hardware-configuration.nix` — it's generated, keep additions in separate modules.

## NOTES

- **Containers are NixOS containers** — each defines a full `containers.<name> = { config = { ... }; }` with interior `system.stateVersion`. The `attic.nix` (103 lines) is the most complex module. All containers follow a shared template: `autoStart`, `privateNetwork`, `macvlans`, `bindMounts`, nested `config`.
- **`macvlan-shim.nix`** is the only module using `lib.mkIf` + assertions — it solves a niche ARP/routing problem for container macvlan networking.
- **`slimevr.nix`** uses `symlinkJoin` + `makeWrapper` — the only custom derivation in `modules/`.
- **No formal NixOS tests** exist — `nixosTest` / `make-test` infrastructure is absent. Verification is via `nix flake check`, `dry-build`, and `nixos-rebuild test`.
