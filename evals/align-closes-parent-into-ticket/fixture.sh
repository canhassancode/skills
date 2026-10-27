#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/shipco-integration src/orders

cat > package.json <<'JSON'
{ "name": "shop-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > src/orders/order.js <<'JS'
export function createOrder(id, totalPence) {
  return { id, status: 'paid', totalPence }
}
JS

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

Status: needs-alignment

## Background
Support keep hand-buying labels on ShipCo's site after checkout.

## Problem statement
Customers can't buy shipping at checkout or see tracking on their order.

## Triage notes
Raised by support; no design yet.

## Comments
MD

git init --quiet --initial-branch=main
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: orders"
