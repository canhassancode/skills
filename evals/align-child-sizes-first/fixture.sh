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
Operators buy, void and reprint ShipCo labels from the order page.

## Rules every child follows
- Anything that charges money is idempotent per order.
- A voided label is refunded by ShipCo within 30 days; after that, voiding is refused.
- Every label action is written to the order's history with the operator's name.

## Journeys
1. An operator buys a label for an order and prints it.
2. An operator voids a label bought by mistake and sees the refund pending.
3. An operator reprints a lost label without buying a new one.

## Children, in build order
- [x] 01 Quote rates — show delivery options and prices for a basket.
- [ ] 02 Labels — buy, void and reprint a label from the order page.

## Comments
MD

cat > .scratch/shipco-integration/issues/02-labels.md <<'MD'
# Labels

Status: needs-alignment
Parent: .scratch/shipco-integration/shipco-integration.md

## Goal
Buy, void and reprint a label from the order page.

## Behaviour
Drafts: `/align` settles these before the build.
- An operator buys a label for a chosen rate.
- An operator voids a label.
- An operator reprints a label.

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

git init --quiet --initial-branch=main
git add --all
commit "feat: quote rates"
