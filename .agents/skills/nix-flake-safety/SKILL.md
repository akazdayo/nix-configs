---
name: nix-flake-safety
description: Use iets by default for local Nix flake operations and avoid copying ignored build artifacts into the Nix store. Use whenever working with `iets`, `nix develop`, `nix build`, `nix flake check`, `nix eval`, `nix run`, or `nixos-rebuild` against a local Git worktree.
---

# Nix Flake Safety

## Use iets by default

- Run Nix CLI commands through `iets nix …` by default. Its compatibility mode delegates unsupported commands or flags to Nix automatically, including `iets nix flake check`, `iets nix flake lock`, and `iets nix run .#app`.
- Use native `iets` commands when you want their specific behavior, such as `iets build .#checks` to build only the check derivations. Native commands do not automatically fall back to Nix.
- Use `nix` directly if `iets` is unavailable. Run standalone tools such as `nixos-rebuild` directly.

## Local Flake References

- Never use `path:.` for a local flake.
- Do not replace it with `path:/absolute/path`. The explicit `path:` scheme bypasses Git filtering and can copy ignored or untracked directories such as `target/`, `.direnv/`, and `.rustfs/` into `/nix/store`.
- In a Git worktree, use the Git-filtered `.` and `.#attribute` forms:

```bash
iets nix develop .
iets nix develop .#shell -c command
iets nix build .#package
iets nix flake check
iets nix eval .#attribute
sudo nixos-rebuild switch --flake .#host
```

- When operating on another local Git worktree, change the command's working directory to that repository and use the same `.` or `.#attribute` forms.
- Before suggesting a path-style workaround, check whether the directory is a Git worktree. If it is not, initialize or use a Git-backed flake unless the user explicitly requires path-flake semantics.

## Disk-Safety Check

If a local flake unexpectedly consumes significant disk space, inspect `/nix/store/*-source` and the worktree's ignored build directories. Repeated multi-gigabyte `*-source` paths usually indicate that an explicit `path:` flake copied the whole worktree.
