#!/bin/sh

readiness="$(dirname "$0")/../engineering/cut/READINESS.md"
row=$(grep -F '| 4 |' "$readiness")

if [ -z "$row" ]; then
  echo "row 4 not found in $readiness"
  exit 1
fi

missing=0

require() {
  if ! printf '%s\n' "$row" | grep -qF -- "$2"; then
    echo "row 4 is missing: $1"
    missing=1
  fi
}

require "one decided-by line decides every criterion" 'one ``Each decided by `<command>`.`` line decides every criterion'
require "another command becomes a test or its own ticket" 'a check that needs another command becomes a test under it or its own ticket'
require "the list item grammar" '`` - [ ] Cn · Sn[, Sn] · `path`[, `path`]: what it shows ``'
require "paths followed immediately by a colon" 'backticked paths followed immediately by `: `'
require "test title after the colon, never between" 'with a test title written after the colon, never between'
require "the Live grammar" 'a **Live** criterion reads `**Live**: <what is run> Passing: <evidence>`'
require "each falsifiable" 'each falsifiable'
require "every scenario has one" 'every scenario has one'

exit "$missing"
