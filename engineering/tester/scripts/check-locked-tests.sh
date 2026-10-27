#!/usr/bin/env bash
set -euo pipefail

locked_pattern='(\.acceptance\.|\.properties\.|\.contract\.|(^|/)e2e/)'
lock_commit="$(git log -1 --format=%H --grep='^test: lock ')"

if [[ -z "$lock_commit" ]]; then
  echo "No 'test: lock' commit on this branch; nothing is locked."
  exit 0
fi

lock_label="$(git log -1 --format='%h %s' "$lock_commit")"
changed="$(git diff --name-only "$lock_commit" HEAD | grep -E "$locked_pattern" || true)"

if [[ -n "$changed" ]]; then
  echo "Locked tests changed after $lock_label:"
  echo "$changed"
  exit 1
fi

echo "Locked tests unchanged since $lock_label."
