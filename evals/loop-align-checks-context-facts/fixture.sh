#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/refunds/issues src/orders src/ports

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

cat > .scratch/refunds/issues/01-refund-a-line.md <<'MD'
# Refund one line of an order

Status: needs-alignment

## Goal
Support refunds one basket line at a time instead of the whole order.

## Behaviour
Drafts: `/align` settles these before the build.
- Refund a line.
- Don't refund twice.

## Comments
MD

cat > src/orders/order.js <<'JS'
export function createOrder({ id, chargeId, lines }) {
  return { id, chargeId, lines: lines.map((line) => ({ ...line, refunded: false })) }
}
JS

cat > src/ports/payment-gateway.js <<'JS'
export function createPaymentGateway(client) {
  return {
    async charge(cardToken, amountPence) {
      return client.post('/charges', { cardToken, amountPence })
    },
    async refund(chargeId) {
      return client.post(`/charges/${chargeId}/refund`, {})
    },
  }
}
JS

git init --quiet --initial-branch=main
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "chore: init shop"
