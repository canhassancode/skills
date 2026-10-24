#!/bin/sh
# Each named SKILL.md resolves VAULT_ROOT once and builds every vault path from it:
# at most one literal ~/Obsidian, and only as VAULT_ROOT's stated default.
# The resolution comes before the first $VAULT_ROOT path, and tells the agent to
# substitute the resolved absolute path, since shell state does not persist.
status=0
for f in "$@"; do
  if [ ! -f "$f" ]; then echo "FAIL $f: missing"; status=1; continue; fi
  literal=$(grep -c '~/Obsidian' "$f")
  if [ "$literal" -gt 1 ]; then
    echo "FAIL $f: $literal lines carry a literal ~/Obsidian"; status=1
  fi
  if grep '~/Obsidian' "$f" | grep -vq 'VAULT_ROOT'; then
    echo "FAIL $f: ~/Obsidian appears outside the VAULT_ROOT default"; status=1
  fi
  if ! grep -q '\$VAULT_ROOT/' "$f"; then
    echo "FAIL $f: no path is built from \$VAULT_ROOT"; status=1
  fi
  if ! grep 'Resolve it once' "$f" | grep -q 'substitute the resolved path'; then
    echo "FAIL $f: does not say to substitute the resolved path into commands"; status=1
  fi
  resolve=$(grep -n 'Resolve it once' "$f" | head -1 | cut -d: -f1)
  first=$(grep -n '\$VAULT_ROOT/' "$f" | head -1 | cut -d: -f1)
  if [ -z "$resolve" ] || { [ -n "$first" ] && [ "$resolve" -gt "$first" ]; }; then
    echo "FAIL $f: the resolution comes after the first \$VAULT_ROOT path"; status=1
  fi
done
[ "$status" -eq 0 ] && echo "ok: $*"
exit "$status"
