#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p docs/agents .scratch/shipco-integration/issues src/shipping

cat > package.json <<'JSON'
{ "name": "shop-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > docs/agents/issue-tracker.md <<'MD'
# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`.

- A ticket is `.scratch/<feature-slug>/issues/<NN>-<slug>.md`; a parent's ticket is `.scratch/<feature-slug>/<feature-slug>.md`
- A spec is its ticket file's body: everything between the header lines and `## Comments`, replaced whole when `/align` writes it
- State is a `Status:` line near the top of the file
- Comments append under a `## Comments` heading at the bottom
MD

cat > .scratch/shipco-integration/shipco-integration.md <<'MD'
# ShipCo integration

## Goal
Customers buy a ShipCo label at checkout and see tracking on their order.

## Rules every child follows
- Anything that charges money is idempotent per order.

## Children, in build order
- [x] 01 Quote rates — show delivery options and prices for a basket.
- [ ] 02 Buy a label — buy a label for a chosen rate and store its tracking number.

## Decisions
- 2026-10-30 Q: Retry a 409 from ShipCo? → A: No; it means the label exists, so fetch it (spike).

## Comments
MD

cat > .scratch/shipco-integration/issues/02-buy-a-label.md <<'MD'
# Buy a label

Status: needs-alignment
Parent: .scratch/shipco-integration/shipco-integration.md

## Goal
Buy a label for a chosen rate and store its tracking number on the order.

## Behaviour
Drafts: `/align` settles these before the build.
- A valid rate buys a label and stores the tracking number on the order.
- An expired rate is reported as rate_expired and nothing is stored.

## Comments
MD

git init --quiet --initial-branch=main
git add --all
commit "feat: quote rates"
