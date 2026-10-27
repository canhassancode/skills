#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/shipco-integration src/orders

cat > src/orders/order.ts <<'TS'
export type OrderStatus = 'paid' | 'awaiting_label' | 'shipped' | 'delivered'

export type Order = {
  id: string
  status: OrderStatus
}
TS

cat > .scratch/shipco-integration/shipco-integration.md <<'MD'
# ShipCo integration

Status: ready-to-cut

## Goal
Customers buy a ShipCo label at checkout and see tracking on their order.

## Out of scope
Returns, customs, multi-parcel shipments, a second carrier.

## Shape
- One module, `shipping`; the app calls only `createShipping`.
- `shipping` reaches ShipCo only through the `Carrier` interface.

## Rules every child follows
- The API key comes from `SHIPCO_API_KEY` and is never logged.
- Anything that charges money is idempotent per order.
- Webhooks are signature-checked before anything else is read.

## Journeys
1. A customer checks out and sees a tracking number.
2. ShipCo reports delivery and the order shows delivered.

## Children, in build order
1. Quote rates — show delivery options and prices for a basket.
2. Shipments table — create the shipments table and its repository.
3. Buy a label — buy a label for a chosen rate and store its tracking number.
4. Track a shipment — show the tracking number and ShipCo's latest status on the order page.

## Decisions
- 2026-10-20 Q: Do ShipCo webhooks arrive signed? → A: Yes, HMAC-SHA256 (spike).
MD

git init --quiet --initial-branch=main
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "docs: shipco integration parent spec"
