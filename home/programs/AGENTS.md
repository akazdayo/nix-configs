# home/programs

**Generated:** 2026-05-22 | **Commit:** 951517d
Parent: [root AGENTS.md](../../AGENTS.md)

## OVERVIEW

Per-program Home Manager configuration — 12 `.nix` files plus the `nixvim/` subtree. Each file configures a single program or service for the user environment.

## STRUCTURE

```
home/programs/
├── cursor.nix              # Custom cursor theme
├── files.nix               # Managed dotfiles in home directory
├── flameshot.nix           # Screenshot tool
├── git.nix                 # Git user config, LFS, SSH signing
├── immich_backups.nix      # Immich photo backup service
├── niri.nix                # Niri compositor (Wayland)
├── nixvim/                 # Neovim via NixVim (23 files, see own AGENTS.md)
├── noctalia.nix            # Noctalia shell integration
├── nushell.nix             # Nushell, carapace, starship, direnv
├── obs.nix                 # OBS Studio
├── secrets.nix             # sops-nix HM config + CLI tools (sops, age)
├── ssh.nix                 # SSH match blocks (GitHub, host-local)
└── vscode.nix              # VS Code editor config
```

## WHERE TO LOOK

| Task                   | Location                          | Notes                                     |
| ---------------------- | --------------------------------- | ----------------------------------------- |
| Add new program module | Create `home/programs/<name>.nix` | Register in `home/profiles/<profile>.nix` |
| Configure Neovim       | `home/programs/nixvim/`           | Own AGENTS.md with plugin conventions     |
| Add dotfile            | `home/programs/files.nix`         | Uses `home.file`                          |
| Shell config           | `home/programs/nushell.nix`       | Sources dotfiles via `builtins.readFile`  |
| Secrets management     | `home/programs/secrets.nix`       | sops + age + yubikey                      |

## CONVENTIONS

- **One file = one program**: Each file configures a single `programs.<name>` or `services.<name>` block. Do not combine unrelated programs.
- **Registration**: New program modules must be imported from the appropriate `home/profiles/<profile>.nix`. Which profile imports which program:
  - `desktop.nix`: git, ssh, files, flameshot, vscode, noctalia, niri, cursor, nushell, nixvim, obs, immich_backups, secrets
  - `server.nix`: git, nushell, nixvim, secrets
  - `openstack.nix`: git, nushell, nixvim
  - `darwin.nix`: git, ssh, nushell, nixvim, secrets
- **Platform conditionals**: Use `pkgs.stdenv.isDarwin` or `pkgs.stdenv.isLinux` for platform-specific settings.
- **hostMeta access**: Programs needing host-specific data (like SSH match blocks) receive `hostMeta` and access via `hostMeta.hostData.<key>`.
- **nushell dotfiles**: `nushell.nix` reads `dotfiles/config.nu` and `dotfiles/env.nu` via `builtins.readFile` rather than using `configFile.source`.
- **nixvim indirection**: nixvim uses a `nixvim-module` specialArg passthrough — configured in `flake.nix`, not as a direct input import. See `home/programs/nixvim/AGENTS.md`.

## ANTI-PATTERNS

- Combining multiple programs in one file — split into separate files per program.
- Forgetting to register new program modules in the relevant `home/profiles/<profile>.nix`.
- Adding Linux-only program config without platform guard on Darwin profiles.
- Using `extraConfig` instead of the nix module's native options when the option exists.

## NOTES

- `home/programs/` is flat (no subdirectories except `nixvim/`) — new programs go at the top level.
- `secrets.nix` enables sops-nix but has no active HM-managed secrets yet (only CLI tools installed).
- `niri.nix` is the largest single file at ~600+ lines — contains full Wayland compositor config.
- `nushell.nix` includes direnv enablement per-user (no root `.envrc` exists).
