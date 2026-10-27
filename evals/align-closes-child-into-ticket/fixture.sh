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

## Out of scope
Returns, customs, multi-parcel shipments, a second carrier.

## Shape
- One module, `shipping`; the app calls only `createShipping`.

## Rules every child follows
- Anything that charges money is idempotent per order.

## Journeys
1. A customer checks out and sees a tracking number.

## Children, in build order
- [x] 01 Quote rates — show delivery options and prices for a basket.
- [ ] 02 Buy a label — buy a label for a chosen rate and store its tracking number.

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

git init --quiet --initial-branch=feat/buy-a-label
git add --all
commit "feat: quote rates"

cat > src/shipping/buy-label.js <<'JS'
export async function buyLabel(orderId, rateId) {
  throw new Error('not implemented')
}
JS
git add src/shipping/buy-label.js
commit "feat: stub buy a label interface"

cat > src/shipping/buy-label.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { buyLabel } from './buy-label.js'

test('A valid rate buys a label and stores the tracking number on the order.', async () => {
  const label = await buyLabel('order-1', 'rate-1')
  assert.match(label.trackingNumber, /^SC/)
})

test('Buying twice for the same order returns the first label and charges once.', async () => {
  const first = await buyLabel('order-2', 'rate-1')
  const second = await buyLabel('order-2', 'rate-1')
  assert.equal(second.trackingNumber, first.trackingNumber)
})
JS
git add src/shipping/buy-label.acceptance.test.js
commit "test: lock buy a label tests"
