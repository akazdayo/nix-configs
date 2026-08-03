# AGENTS.md

## Build and verification

- Apply NixOS: `nh os switch` or `sudo nixos-rebuild switch --flake .#<host>`
- Dry-build NixOS: `nixos-rebuild dry-build --flake .#<host>`
- Apply Darwin: `nix run nix-darwin -- switch --flake .#chiffon`
- Check: `nix flake check`
- Format: `nix fmt`
- Dev shell: `nix develop`
- Update inputs: `nix flake update` or `nix flake lock --update-input <name>`

When running a local Nix flake command, use `.` or `.#<attribute>`. Never use an explicit `path:` reference for this Git worktree.

## Architecture

The composition chain is deliberately short:

```text
flake.nix -> hosts/<name>/default.nix -> leaf modules
```

- `flake.nix` owns inputs, generic NixOS/Darwin builders, `hostMeta`, deploy outputs, checks, and development tooling. It must not select host features.
- `hosts/<name>/default.nix` is the only composition list for that host. It directly imports hardware, external modules, NixOS/Darwin leaf modules, and Home Manager program/package modules.
- `hosts/<name>/default.nix` also owns every host-local literal and supplies reusable modules through `local.*` options.
- `modules/nixos/` is organized by function. Multi-file domains use directories such as `networking/`, `hardware/`, `containers/`, `minecraft/`, and `nix/`; single-file features stay at the directory root.
- `modules/darwin/` contains active nix-darwin leaf modules only. Do not add empty platform-mirroring placeholders.
- `home/programs/` contains one Home Manager program concern per file.
- `home/packages/` contains purpose-based package groups.
- `infra/openstack/` is OpenTofu infrastructure and follows its nested `AGENTS.md`.
- `dotfiles/` contains static files only; `secrets/` contains encrypted data only.

There is no `profiles/` or `home/profiles/` layer. Do not recreate bundle modules or import-only `default.nix` files. A host import list may be long so that enabled features remain explicit.

## Module rules

- New system or Home Manager modules must be imported directly by each applicable `hosts/<name>/default.nix`.
- Repository leaf modules contain concrete settings and do not import other repository leaf modules. Importing a required external flake module is allowed.
- Use lowercase kebab-case names. Add a subdirectory only when a feature has multiple independent files or accompanying assets.
- Reusable modules expose host-specific inputs as `local.<feature>.*` options. Importing a module enables that feature, so do not add a redundant `enable` option.
- Use `hostMeta.platform` and `hostMeta.role` for platform/role behavior. Use `hostMeta.hostName` only for genuinely host-specific behavior.
- Keep `system.stateVersion = "25.11"`, `home.stateVersion = "25.11"`, and Darwin `system.stateVersion = 6` in host defaults.
- Use `pkgs-unstable` only when a package specifically needs the unstable set. `pkgs-with-llm-agents` is Home Manager-only.
- Format Nix with `nixfmt-rfc-style`; repository formatting is defined by `treefmt.nix`.

## Safety boundaries

- Do not modify the contents of any `hardware-configuration.nix`; hardware additions belong in a role module.
- Do not hardcode host-specific IP addresses, interfaces, mount paths, authorized keys, or service paths in reusable modules. Put those literals in the applicable host's `default.nix` and pass them through `local.*` options.
- Do not move, rename, decrypt, or rekey tracked encrypted files unless explicitly requested. Secret path rules live in `.sops.yaml`.
- `/etc/nextcloud-adminpass` and `/etc/searx-env` are intentional legacy host-local secrets; do not migrate them without an explicit task.
- Preserve unrelated worktree changes and ignored Terraform state. Never run OpenTofu `apply` without reviewing a plan.

## CI and deployment

- Pull requests run `nix flake check --no-build` and build Milk, Hinata, Gateway, Minecraft, and Chiffon.
- Scheduled dependency updates build all hosts before committing `flake.lock`.
- OpenStack deployments use `nix run .#deploy-openstack -- <host>`, which resolves the address from OpenTofu output.
- Deploy-rs nodes cover Milk, Hinata, Gateway, and Minecraft. Milfy and Chiffon are not deploy-rs targets.
