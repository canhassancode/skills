/align .scratch/split-shipments/split-shipments.md — we've done this one in this session: tiered as a known parent, the red team said go, and I approved every section of the parent spec below. Close the session. There's no remote here.

## Goal
An order that ships in several parcels gets one label per parcel and shows every tracking number.

## Out of scope
Returns, customs, a second carrier.

## Shape
- One module, `shipping`; a parcel belongs to one order and carries its own label.

## Rules every child follows
- Worth building because about 5% of orders on production ship in more than one parcel.

## Journeys
1. A customer orders a sofa and a lamp, they ship separately, and the order shows both tracking numbers.

## Children, in build order
1. Label per parcel — buy one label for each parcel of an order.
2. Show every tracking number — the order page lists each parcel's tracking number.

## Decisions
- 2026-10-27 Q: One label for the whole order? → A: No; the carrier needs one per parcel.
