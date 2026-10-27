/align .scratch/rate-quotes/rate-quotes.md — we've done this one in this session: tiered as a known parent, the red team said go, and I approved every section of the parent spec below. The quote-time spike timed one call to ShipCo's live rates endpoint, the one checkout calls. Close the session. There's no remote here.

## Goal
Checkout shows delivery options and prices without calling ShipCo on every page view.

## Out of scope
Labels, tracking, a second carrier.

## Shape
- One module, `shipping`; checkout calls only `quoteRates`.

## Rules every child follows
- A quoted rate is reused for 15 minutes, then quoted again.
- Checkout waits for a fresh quote only when ShipCo answers inside the page's 500 ms budget.

## Journeys
1. A customer opens checkout twice in a minute and ShipCo is asked once.

## Children, in build order
1. Cache quotes — reuse a basket's quote until it expires.
2. Expire quotes — re-quote a basket once its quote is older than the limit.

## Decisions
- 2026-10-27 Q: How long does ShipCo take to quote one basket? → A: About 300 ms, so a fresh quote fits the budget (spike).
- 2026-10-27 Q: Cache per basket or per customer? → A: Per basket; the price depends on the parcel.
