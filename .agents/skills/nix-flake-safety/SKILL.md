---
name: nix-flake-safety
description: Run and recommend local Nix flake commands without copying ignored build artifacts into the Nix store. Use whenever working with `nix develop`, `nix build`, `nix flake check`, `nix eval`, `nix run`, or `nixos-rebuild` against a local Git worktree.
---

# Nix Flake Safety

## Local Flake References

- Never use `path:.` for a local flake.
- Do not replace it with `path:/absolute/path`. The explicit `path:` scheme bypasses Git filtering and can copy ignored or untracked directories such as `target/`, `.direnv/`, and `.rustfs/` into `/nix/store`.
- In a Git worktree, let Nix discover the Git flake and use references such as:

```bash
nix develop
nix develop .#shell -c command
nix build .#package
nix flake check
nix eval .#attribute
sudo nixos-rebuild switch --flake .#host
```

- When operating on another local Git worktree, change the command's working directory to that repository and use the same `.` or `.#attribute` forms.
- Before suggesting a path-style workaround, check whether the directory is a Git worktree. If it is not, initialize or use a Git-backed flake unless the user explicitly requires path-flake semantics.

## Disk-Safety Check

If a local flake unexpectedly consumes significant disk space, inspect `/nix/store/*-source` and the worktree's ignored build directories. Repeated multi-gigabyte `*-source` paths usually indicate that an explicit `path:` flake copied the whole worktree.
