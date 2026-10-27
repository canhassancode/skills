/align .scratch/shipco-integration/shipco-integration.md — we've done this one in this session: tiered as a known parent, the red team said go, and I approved every section of the parent spec below. Close the session. There's no remote here.

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

## Journeys
1. A customer checks out and sees a tracking number.

## Children, in build order
1. Quote rates — show delivery options and prices for a basket.
2. Buy a label — buy a label for a chosen rate and store its tracking number.
3. Track a shipment — the order page shows the tracking number.

## Decisions
- 2026-10-27 Q: Do ShipCo webhooks arrive signed? → A: Yes, HMAC-SHA256 (spike).
