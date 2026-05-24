# AGENTS.md

**Generated:** 2026-05-22 | **Commit:** 951517d | **Branch:** main

## Build & Test Commands
- **Apply Config (NixOS, preferred)**: `nh os switch` (auto-cleans old generations, 4d/3 gen retention)
- **Apply Config (NixOS, explicit)**: `sudo nixos-rebuild switch --flake .#nixos` (replace `nixos` with `server` as needed)
- **Test Config (NixOS)**: `sudo nixos-rebuild test --flake .#nixos`
- **Dry Run (NixOS)**: `nixos-rebuild dry-build --flake .#nixos`
- **Apply Config (Darwin)**: `nix run nix-darwin -- switch --flake .#macbook`
- **Lint/Check**: `nix flake check` (also runs deploy-rs checks)
- **Update deps**: `nix flake update` (all) or `nix flake lock --update-input <name>`
- **Dev shell**: `nix develop` (provides deploy-rs, nixfmt-rfc-style, sops, age tools)

## CI (GitHub Actions)
- **PR Build** (`pr-build.yml`): On PR to main — builds all 4 hosts (nixos, server, gateway on ubuntu-latest; macbook on macos-latest). Uses Cachix (read-only).
- **Scheduled Update** (`flake-update.yml`): Every 3 days — updates flake.lock, builds all hosts, pushes to Cachix + Attic, commits updated lock file.
- No formal NixOS tests exist. Verification is via `nix flake check`, dry-build, and CI builds.

## Architecture

Import chain: `flake.nix` → host (`hosts/<name>/default.nix` or `hosts/openstack/<name>/default.nix`) → profile (`profiles/<platform>/<type>/<name>/default.nix` where grouped) → module domain (`modules/<platform>/<domain>/<variant>.nix`)

- `flake.nix`: Four builder functions — `mkHost` (desktop NixOS), `mkServer` (server NixOS), `mkOpenStackHost` (cloud VM NixOS), `mkDarwinHost` (macOS). Each constructs `hostMeta`, resolves `hostData`, wires `specialArgs` + `extraSpecialArgs`.
- **hostMeta** (passed to all NixOS + HM modules): `{ hostName, system, primaryUser, flakeRoot, hostData }`. `hostData` is resolved via a two-pass pattern: `baseHostMeta` → import `host-data.nix` → extract `_module.args.hostData` → merge into `hostMeta`.
- **specialArgs (NixOS)**: `self`, `inputs`, `pkgs-unstable`, `hostMeta`
- **extraSpecialArgs (home-manager)**: same as system + `pkgs-with-llm-agents` + `nixvim-module`
- **Flake inputs** (14): nixpkgs (25.11), nixpkgs-unstable, home-manager, nix-darwin, nixvim, lanzaboote, deploy-rs, nix-flatpak, noctalia, llm-agents, minecraft-nix, nix-cachyos-kernel, sops-nix
- **Outputs**: `nixosConfigurations.{nixos,server,gateway}`, `darwinConfigurations.macbook`, `deploy.nodes`, `checks` (deploy-rs), `devShells`

## Code Style & Conventions
- **Structure**: Platform-first modular Flake. System settings live under `modules/<platform>/`, user settings under `home/`.
- **Modules**: Use `default.nix` as directory entry point for multi-file domains. Import sub-modules in `default.nix`.
- **Arguments**: Modules typically accept `{ pkgs, pkgs-unstable, ... }`. Host-aware modules also receive `hostMeta`; access host-specific values via `hostMeta.hostData.<key>` — never hardcode.
- **Profile registration**: Profiles are pure aggregators (`{ imports = [...]; }`). NixOS desktop profile imports 15 modules; server imports 12.
- **Registration**:
  - NixOS system modules: imported by `profiles/nixos/*.nix`.
  - Darwin system modules: imported by `profiles/darwin/*.nix`.
  - Home Manager modules: imported by `home/profiles/*.nix`.
- **Formatting**: `nixfmt-rfc-style` (canonical, in devShell). `alejandra` also available as user package.
- **Versions**: Maintain `system.stateVersion = "25.11"` (NixOS) and `home.stateVersion = "25.11"`. Darwin hosts use integer `system.stateVersion` (for example, `6`).
- **Packages**: Use `pkgs-unstable` for newer software if needed (passed via `specialArgs`). Three package sets: `pkgs` (stable), `pkgs-unstable`, `pkgs-with-llm-agents` (HM-only). All have `allowUnfree = true`.

## Strict File & Directory Rules
- **Directory Boundaries**:
  - `hosts/<host>/default.nix` and `hosts/openstack/<host>/default.nix`: Host composition only. Must be a thin wrapper importing a profile, hardware config, and `host-data.nix`. No direct feature settings.
  - `hosts/<host>/host-data.nix` and `hosts/openstack/<host>/host-data.nix`: Host-local literals only (network addresses, interfaces, mount paths, swap path, SSH authorized keys, container paths). No reusable module logic.
  - `modules/nixos/`: NixOS system settings only.
  - `modules/darwin/`: Darwin system settings only.
  - `modules/shared/`: Cross-platform modules only. Must be safe to evaluate on both NixOS and Darwin. Currently a placeholder.
  - `profiles/nixos/`: NixOS profile aggregators. Each file bundles modules for a host type (desktop, server, openstack).
  - `profiles/darwin/`: Darwin profile aggregators.
  - `home/profiles/`: Home Manager profile aggregators. Each file bundles program configs and package groups for a host type (desktop, server, openstack, darwin).
  - `home/packages/`: Home Manager package groups by purpose. Each file sets `home.packages`. Platform-conditionals inside files (via `pkgs.stdenv.isLinux` or `hostMeta.hostName` checks) keep Darwin from inheriting Linux-only tools.
  - `home/programs/`: Per-program Home Manager configuration.
  - `packages/`: overlays and derivations only.
  - `dotfiles/`: static files only (no Nix option definitions).
- **Entry Points**:
  - Use `default.nix` as the directory entry point.
  - `default.nix` should primarily import child modules; keep concrete settings there minimal.
- **Single Responsibility**:
  - Keep one primary concern per file.
  - Match file name to primary option group (example: `packages.nix` manages `home.packages`).
  - Do not mix unrelated domains in one file (example: desktop/locale/networking split).
- **Naming**:
  - New file and directory names must use lowercase kebab-case.
  - **NixOS module naming**: Primary convention is host-type suffix (`desktop.nix` / `server.nix` / `openstack.nix`) per domain. Exceptions: service-specific names (`minecraft-server.nix`, `cloudflared.nix`), feature-specific names (`nvidia.nix`, `cachyos-kernel.nix`), and aggregation entry points (`desktop/default.nix`). The domain directory name matches the primary option group; variant file names distinguish host type or feature.
- **Profile Registration**:
  - New NixOS modules must be imported from a `profiles/nixos/*.nix` file, not directly from a host entry.
  - New Darwin modules must be imported from a `profiles/darwin/*.nix` file.
  - New Home Manager profiles must be imported from `home/profiles/*.nix`.
  - New package groups must be imported from the relevant `home/profiles/*.nix`.
- **Host-Local Data**:
  - Static host values (IP addresses, interface names, gateway, DNS, mount paths, swap file path, SSH authorized keys, Immich paths/URLs, container service paths) belong in `hosts/<host>/host-data.nix`.
  - Reusable modules must read these values from `hostMeta.hostData`, never hardcode them.
- **Security (Principle with Exceptions)**:
  - Principle: Do not hardcode secrets (API keys, tokens, passwords) in tracked files.
  - Exception: Local-only non-privileged values may be temporarily allowed when unavoidable.
  - When using an exception, document reason and scope inline, and plan migration to secret management or environment variables.
- **Secret Path Freeze**:
  - Do not move, rename, or rekey tracked encrypted secret files during repo structure work.
  - Current tracked encrypted files: `secrets/nixos/home.yaml`.
  - Other `secrets/` subdirectories contain only `.gitkeep` placeholders.
  - Legacy container secret paths (`/etc/nextcloud-adminpass`, `/etc/searx-env`) remain host-local files. Do not migrate them to sops-nix without an explicit task.
- **Deploy Coverage**:
  - `deploy-rs` nodes cover `nixos` (192.168.11.48), `server` (192.168.11.50), and `gateway` (via `nix run .#deploy-openstack` — resolves SSH host from tofu output dynamically).
  - Darwin hosts are not deployable via deploy-rs.
- **Non-Standard Root Directories**:
  - `cursors/`: Custom cursor theme derivations. Not a standard flake repo directory.
  - `wallpapers/`: Static binary assets (.png) tracked in repo.
  - `infra/`: OpenTofu/Terraform IaC for OpenStack provisioning. Separate from Nix config.
  - `openrc.sh`: OpenStack auth helper script at repo root.
  - `scripts/`: Does NOT exist (contrary to README tree diagram).
  - `packages/` is dual-role: both a NixOS module (sets `nixpkgs.overlays` via auto-discovery) and a potential flake output container. The overlay auto-discovery (`builtins.readDir` + `callPackage`) is a bespoke pattern.
  - `profiles/{nixos,darwin}/default.nix` and `home/profiles/default.nix` are empty placeholder scaffolds — not active entry points.
