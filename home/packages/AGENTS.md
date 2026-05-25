# home/packages

**Generated:** 2026-05-19 | **Commit:** 94337f6
Parent: [root AGENTS.md](../../AGENTS.md)

## OVERVIEW

Home Manager package groups — 10 files, each setting `home.packages` for a specific purpose. Imported by `home/profiles/*.nix`.

## STRUCTURE

```
home/packages/
├── default.nix         # Combined import of all groups (unused currently)
├── core.nix            # Shared CLI tools (git, curl, fd, ripgrep, etc.)
├── desktop.nix         # Desktop GUI apps (firefox, obs, krita, yt-dlp)
├── development.nix     # Dev tools (gcc, python, nodejs, rustup)
├── media.nix           # Media tools (imagemagick, ffmpeg, etc.)
├── wayland.nix         # Wayland-specific tools (wl-clipboard, grim, slurp, etc.)
├── gaming.nix          # Gaming tools (cider2, prismlauncher, etc.)
├── llm.nix             # LLM agents (opencode, claude-code)
├── server.nix          # Server-specific (tailscale, attic-client, etc.)
└── darwin.nix          # macOS-specific (nerd-fonts, ffmpeg)
```

## WHERE TO LOOK

| Task                           | Location          | Notes                               |
| ------------------------------ | ----------------- | ----------------------------------- |
| Add CLI tool shared everywhere | `core.nix`        | Use platform conditionals if needed |
| Add desktop app                | `desktop.nix`     |                                     |
| Add dev tool                   | `development.nix` |                                     |
| Add macOS-specific package     | `darwin.nix`      |                                     |

## CONVENTIONS

- **File = purpose group**: Each file maps to a user-facing category (core, desktop, development, etc.), matching its `home/profiles/<profile>.nix` import.
- **Platform conditionals inside files**: Use `pkgs.stdenv.isLinux` / `pkgs.stdenv.isDarwin` to gate Linux/macOS-only packages. Use `hostMeta.hostName == "nixos"` for desktop-specific selections (e.g., `btop-cuda` vs `btop`). Use `lib.optionals` for clean conditional lists.
- **Registration**: New package groups must be imported from the relevant `home/profiles/<profile>.nix`. Which profile imports which groups:
  - `desktop.nix`: core, desktop, development, media, wayland, gaming, llm
  - `server.nix`: core, server
  - `darwin.nix`: core, development, darwin, llm
- **`pkgs-with-llm-agents`**: Only for `llm.nix` — uses a separate pkgs instance with the `llm-agents` overlay (from `numtide/llm-agents.nix`). Not available in system modules.
- **Nixfmt**: `nixfmt-rfc-style` is the canonical formatter. `alejandra` is also installed as a user package.

## ANTI-PATTERNS

- Adding Linux-only packages without `pkgs.stdenv.isLinux` guard — breaks Darwin evaluation.
- Using `hostMeta.hostName == "nixos"` as a proxy for "desktop" without confirming it's the intended check.
- Forgetting to register new package groups in the relevant `home/profiles/<profile>.nix`.

## NOTES

- `default.nix` aggregates all groups but is NOT imported by any profile. Profiles import individual group files directly for selective composition.
- The `core.nix` pattern of using `isDesktop = hostMeta.hostName == "nixos"` is a convention used across multiple package files to toggle desktop-only variants.
- All packages use the stable `pkgs` set by default. Use `pkgs-unstable` only via `specialArgs` when a specific package needs a newer version.
