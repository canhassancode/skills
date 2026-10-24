#!/bin/sh

skill="$(dirname "$0")/../engineering/align/SKILL.md"

missing=0

require() {
  if ! grep -qF -- "$2" "$skill"; then
    echo "align SKILL.md is missing: $1"
    missing=1
  fi
}

require "a rule for pass 1 with no ticket" '**Pass 1 with no ticket.**'
require "the new ticket is sized to the ask, not the pass" 'sized to the ask, not to the pass'
require "deferred areas become owed slices or Unresolved entries" 'each area playback deferred as an `owed` slice or an Unresolved entry'
require "a close rule holding playback's Unresolved entries" "**Playback's Unresolved at the close.**"
require "each entry stays, becomes owed, or leaves on a yes" 'is still in Unresolved, is an `owed` slice, or leaves on the user'"'"'s explicit yes'
require "moving to Out of scope is its own question" 'Moving one to Out of scope is its own question'
require "a full pass uses out of scope only with a yes" 'a full pass takes it only with that yes'
require "the check runs before the row is read" 'runs before the row is read'

exit "$missing"
