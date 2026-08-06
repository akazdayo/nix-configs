# Repository Guidelines

## Project Structure & Architecture

```text
flake.nix -> hosts/<name>/default.nix -> leaf modules
```

`flake.nix` defines shared builders, checks, and tooling; it must not select host features. Each `hosts/<name>/default.nix` is the host's only composition list and owns local literals.

- `modules/{nixos,darwin}/`: system leaf modules.
- `home/programs/` and `home/packages/`: Home Manager modules.
- `dotfiles/`: static files; `secrets/`: encrypted data only.
- `infra/openstack/`: OpenTofu configuration governed by its nested `AGENTS.md`.

Import leaf modules directly from applicable host definitions. Do not introduce profiles, bundles, import-only `default.nix` files, or imports between repository leaf modules. Required external flake imports are allowed.

## Build, Test, and Development Commands

- `nix develop`: enter the dev shell.
- `nix fmt`: run treefmt.
- `nix flake check`: evaluate checks and formatting.
- `nixos-rebuild dry-build --flake .#<host>`: test a NixOS host.
- `nh os switch` or `sudo nixos-rebuild switch --flake .#<host>`: apply NixOS.
- `nix run nix-darwin -- switch --flake .#chiffon`: apply Darwin.

For this worktree, use `.` or `.#<attribute>` in local flake commands, never an explicit `path:` reference.

## Coding Style & Module Conventions

Use lowercase kebab-case filenames. Add a directory only for multi-file features or assets. Pass host-specific values through `local.<feature>.*`; importing a module enables it, so omit redundant `enable` options. Prefer `hostMeta.platform` and `hostMeta.role` over hostname checks.

`treefmt.nix` configures nixfmt, Stylua, shfmt, Prettier, and rustfmt. Keep NixOS/Home Manager `stateVersion` at `25.11` and Darwin at `6`. Use `pkgs-unstable` only when required; `pkgs-with-llm-agents` is Home Manager-only.

## Testing & Pull Requests

There is no unit-test suite; flake checks and host builds are the primary verification. Before a PR, run `nix fmt`, `nix flake check`, and dry-build affected hosts. CI checks the flake and builds Milk, Hinata, Gateway, Minecraft, and Chiffon.

Recent commits use brief Japanese summaries, sometimes prefixed with `feat:`. Keep commits focused. PRs should list affected hosts, verification, deployment or secret implications, and screenshots for UI changes.

## Safety & Deployment

Never edit `hardware-configuration.nix`; put hardware additions in a role module. Keep IPs, interfaces, mount paths, keys, and service paths in host definitions and pass them through `local.*`. Do not move, decrypt, or rekey tracked secrets unless requested; `.sops.yaml` owns secret paths. Preserve legacy `/etc/nextcloud-adminpass` and `/etc/searx-env`, unrelated changes, and ignored Terraform state. Review an OpenTofu plan before applying.

Deploy OpenStack hosts with `nix run .#deploy-openstack -- <host>`. Deploy-rs covers Milk, Hinata, Gateway, and Minecraft; Milfy and Chiffon are excluded.
