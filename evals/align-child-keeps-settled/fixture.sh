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

## Journeys
1. A customer checks out and sees a tracking number.

## Children, in build order
- [x] 01 Quote rates — show delivery options and prices for a basket.
- [ ] 02 Buy a label — buy a label for a chosen rate and store its tracking number.

## Decisions
- 2026-10-28 Q: Does a second request for the same order buy a second label? → A: No; return the first label and charge once.

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
- Buying twice for the same order returns the first label and charges once.

## Comments
MD

cat > src/shipping/quote-rates.js <<'JS'
export async function quoteRates(basket) {
  const response = await fetch('https://api.shipco.example/v2/rates', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ parcels: basket.parcels }),
  })
  return response.json()
}
JS

cat > src/shipping/carrier.js <<'JS'
export async function purchaseLabel(rateId) {
  const response = await fetch('https://api.shipco.example/v2/labels', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ rateId }),
  })
  return response.json()
}
JS

git init --quiet --initial-branch=main
git add --all
commit "feat: quote rates"
