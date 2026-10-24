#!/bin/sh
# /file's vault contract.
#   c2: VAULT_ROOT defaults to ~/Obsidian, and every vault path is built from it.
#   c3: one Domains paragraph words the domain folders and hubs as a default
#       example and defers to the vault's own $VAULT_ROOT/CONTEXT.md.
f=personal/file/SKILL.md
status=0
fail() { echo "FAIL $f: $1"; status=1; }

case "$1" in
  c2)
    sh personal/tests/vault_root_test.sh "$f" || status=1
    grep -q 'defaulting to `~/Obsidian` when unset' "$f" || fail "no stated ~/Obsidian default"
    grep -qF '${VAULT_ROOT:-$HOME/Obsidian}' "$f" || fail "no resolution of VAULT_ROOT with its default"
    grep -qF '$VAULT_ROOT/Inbox/' "$f" || fail "Inbox is not built from \$VAULT_ROOT"
    ;;
  c3)
    d=$(grep '^\*\*Domains\.\*\*' "$f")
    [ -n "$d" ] || fail "no Domains paragraph"
    has() { printf '%s\n' "$d" | grep -qF "$1" || fail "Domains paragraph lacks: $1"; }
    has 'Ventures/'
    has 'Home.md'
    has 'Finances.md'
    has 'default example'
    has '$VAULT_ROOT/CONTEXT.md'
    has "domains in the vault's own \`CONTEXT.md\` win"
    ;;
  *) echo "usage: $0 c2|c3"; exit 2 ;;
esac
[ "$status" -eq 0 ] && echo "ok: $1"
exit "$status"
