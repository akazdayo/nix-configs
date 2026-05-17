#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
host_name="${HOST_NAME:-nixos}"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

nix flake update

if git diff --quiet -- flake.lock; then
  echo "No flake.lock changes after update; exiting."
  exit 0
fi

nix build ".#nixosConfigurations.${host_name}.config.system.build.toplevel" --print-build-logs

echo "Build completed. cachix-action will push built paths to Cachix via its post-build hook."

if [[ -n "${ATTIC_CACHE:-}" ]]; then
  if attic push "${ATTIC_CACHE}" ./result; then
    echo "Pushed build result to Attic cache '${ATTIC_CACHE}'."
  else
    echo "Warning: failed to push build result to Attic cache '${ATTIC_CACHE}'; continuing because Cachix is the primary cache." >&2
  fi
else
  echo "Warning: ATTIC_CACHE is not set; skipping Attic push." >&2
fi

git add flake.lock
git commit -m "chore: update flake.lock"
git push origin HEAD:${GITHUB_REF_NAME:-main}
