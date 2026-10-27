# Build examples

The ticket is #42, *Buy a label*, a child of #40 *ShipCo integration*. Its body is the spec, with four behaviour lines locked at `9c41e2a` on `feat/buy-a-label`.

## The unit plan

What the Delegator holds, and all it holds:

```markdown
Lock 9c41e2a · loop: pnpm typecheck · pnpm lint · pnpm test src/shipping · pnpm test

1. Buying stores the label — "A valid rate buys a label and stores the tracking number on the order." · "An expired rate is reported as rate_expired and nothing is stored."
2. Retries and outages — "Buying twice for the same order returns the first label and charges once." · "ShipCo being down is reported as unavailable after retries and nothing is stored."
```

## A stop report

Posted on the ticket when a unit stops; the ticket moves to `needs-alignment`.

```markdown
### Build stopped — 2026-10-28

**Test**  `src/shipping/shipping.properties.test.ts` › "Buying twice for the same order returns the first label and charges once."
**Expects**  the second call's label to deep-equal the first, `createdAt` included.
**Why it can't pass**  ShipCo's 409 answer carries no `createdAt` (spike, Decisions 2026-10-21), so the refetched label has the fetch time. The spec says "returns the first label"; it doesn't say which fields.
**Proposal**  compare `id` and `trackingNumber` only. Changing the line needs `/align #42` and a relock.
**Green so far**  `b7d3f10` unit 1 — pushed.
```

## The pull request

```markdown
## Summary

Buy a ShipCo label for the chosen rate and store its tracking number on the order. Closes #42.

## Behaviour

| Behaviour | Test | Result |
|---|---|---|
| A valid rate buys a label and stores the tracking number on the order. | `shipping.acceptance.test.ts` | green |
| Buying twice for the same order returns the first label and charges once. | `shipping.properties.test.ts` | green, 100 runs |
| An expired rate is reported as rate_expired and nothing is stored. | `shipping.acceptance.test.ts` | green |
| ShipCo being down is reported as unavailable after retries and nothing is stored. | `shipping.acceptance.test.ts` | green |

Lock check: unchanged since `9c41e2a`. Full suite: 412 passed.

## Verify

- [x] POST /api/orders/123/label `{"rateId":"r_1"}` → 201, tracking `SC48213` (output below)
- [x] /orders/123 shows "Tracking: SC48213" under Shipping (`verify/order-123.png`)
- [ ] A ShipCo outage shows "Shipping is unavailable, try again" — not run in session: the sandbox has no way to force a 503. Reviewer: `SHIPCO_BASE_URL=http://localhost:9 pnpm dev`, then buy a label on /orders/123.

## Decided limits

- Label PDF rendering is out of scope (spec).
- A 409 from ShipCo fetches the existing label instead of retrying (spec Decisions, 2026-10-21).

## Pruned

Crucible removed 3 of 5 scratch tests that caught nothing the locked tests miss; kept `mapCarrierError.test.ts` (2 unique kills).
```

## The session comment

```markdown
### Build — 2026-10-28

**Units**  `b7d3f10` buy and store a label · `e1a90c4` replay a purchase and survive outages
**Vet**  crucible: 1 behaviour finding fixed in `5f2c7d8`, 3 scratch tests pruned · verify: 2 of 3 passed, 1 left for the reviewer
**PR**  #57
**Resume**  nothing — complete
```

A run that filled its window instead ends `**Resume**  unit 2 of 2, from b7d3f10`.
