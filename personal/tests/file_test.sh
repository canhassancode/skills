#!/bin/sh
# /file's vault contract.
#   c2: VAULT_ROOT defaults to ~/Obsidian, and every vault path is built from it.
#   c3: the domain folders and hubs are a default example; the vault's own
#       $VAULT_ROOT/CONTEXT.md decides the real domains.
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
    grep -qF '$VAULT_ROOT/CONTEXT.md' "$f" || fail "domain model is not read from \$VAULT_ROOT/CONTEXT.md"
    grep 'Ventures' "$f" | grep -q 'default example' || fail "domain folders are not worded as the default example"
    grep 'Home.md' "$f" | grep -q 'default example' || fail "hubs are not worded as the default example"
    grep -q "domains in the vault's own \`CONTEXT.md\` win" "$f" || fail "does not defer to the vault's CONTEXT.md"
    ;;
  *) echo "usage: $0 c2|c3"; exit 2 ;;
esac
[ "$status" -eq 0 ] && echo "ok: $1"
exit "$status"
