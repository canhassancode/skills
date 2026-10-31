#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/holds/issues src/holds

cat > package.json <<'JSON'
{ "name": "library-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > docs/agents/issue-tracker.md <<'MD'
# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`.

- A ticket is `.scratch/<feature-slug>/issues/<NN>-<slug>.md`; a parent's ticket is `.scratch/<feature-slug>/<feature-slug>.md`
- A spec is its ticket file's body: everything between the header lines and `## Comments`, replaced whole when `/align` writes it
- State is a `Status:` line near the top of the file
- Comments append under a `## Comments` heading at the bottom
MD

cat > .scratch/holds/issues/01-place-a-hold.md <<'MD'
# Place a hold

Status: needs-alignment

## Goal
A member places a hold on a book that is out on loan.

## Behaviour
Drafts: `/align` settles these before the build.
- A member can hold a book.
- A member can't hold too many books.

## Comments
MD

cat > src/holds/index.js <<'JS'
export function createHolds(dependencies) {
  throw new Error('createHolds is not implemented')
}
JS

git init --quiet --initial-branch=feat/place-a-hold
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub place a hold interface"
