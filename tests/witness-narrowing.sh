#!/bin/sh

root="$(dirname "$0")/.."
build="$root/engineering/build/SKILL.md"
crucible="$root/engineering/crucible/SKILL.md"
ticket="$root/engineering/cut/TICKET.md"

missing=0

require() {
  if ! grep -qF -- "$3" "$2"; then
    echo "$(basename "$(dirname "$2")")/$(basename "$2") is missing: $1"
    missing=1
  fi
}

require "the fit table records the narrowing or its reason" "$build" '| **criteria** | one command per criterion, each with its witness — narrowed to the criterion'"'"'s test, or `whole file: <reason>` |'
require "the fit narrows with the runner's own selector" "$build" 'narrow its command to that test with the runner'"'"'s own selector — its flag for running one test by name'
require "the fit narrows in the file that holds the title" "$build" 'With two witness paths, narrow in the file that holds the title.'
require "the fit records the whole-file command with why" "$build" 'the command runs the whole file and the fit records why: `<criterion> → <witness> → <command> · whole file: <reason>`'
require "the Builder brief carries the reason" "$build" 'Witness and command: <criterion> → <witness> → <command>[ · whole file: <reason>]'
require "the unit vet carries the reason" "$build" 'the witness and command of every criterion the unit owns, each with its `whole file: <reason>` where the fit recorded one'
require "the re-vet carries the reason" "$build" 'the round'"'"'s range, the verified list and the fit'"'"'s criteria entries, `whole file: <reason>` included, as its **re-vet**'
require "the whole-branch vet carries the reason" "$build" 'with the contract and the fit'"'"'s criteria entries, `whole file: <reason>` included'

require "step 1 flags an unnarrowed titled criterion as P1 test" "$crucible" 'whose command runs the whole witness file with no `whole file: <reason>` is a **test** finding, P1, naming the criterion'
require "the flag fires only when a fit was passed" "$crucible" 'Only where the caller passed a fit'
require "a Live criterion is never flagged" "$crucible" 'A **Live** criterion is never flagged'
require "no fit raises no narrowing finding" "$crucible" 'Without a fit — `/review` with none, `/diagnose`'"'"'s Phase 6 — no narrowing finding is raised'
require "step 2.2 runs the command as given" "$crucible" '2. Run the **witness**, not the suite — the criterion'"'"'s command as given, never narrowed or widened here.'

require "the criterion line shows a quoted title after the colon" "$ticket" '- [ ] C2 · S1 · `<witness>`: "<test title>" <what that test shows, in one line>.'

exit "$missing"
