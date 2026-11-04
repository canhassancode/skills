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
- [ ] A ShipCo outage shows "Shipping is unavailable, try again" — not run in session: the sandbox has no way to force a 503.
  Ruling (operator, 2026-10-28): the reviewer checks it by hand — `SHIPCO_BASE_URL=http://localhost:9 pnpm dev`, then buy a label on /orders/123.

## Decided limits

- Label PDF rendering is out of scope (spec).
- A 409 from ShipCo fetches the existing label instead of retrying (spec Decisions, 2026-10-21).

## Fix rounds

| Behaviour line | Round | Stopped |
|---|---|---|
| Buying twice for the same order returns the first label and charges once. | `5f2c7d8` (crucible) | 2026-10-28 — second finding, a retry after a timeout charges again; ruled, Decisions 2026-10-28 |
| none | `a3d81e0` (crucible) | — |

## Pruned

Crucible removed 3 of 5 scratch tests that caught nothing the locked tests miss; kept `mapCarrierError.test.ts` (2 unique kills).
```

Align opened this body as a draft; build edits it in place and leaves it a draft until the outage step has its ruling.

## A rule question

Asked in session when a second finding lands on a line that has had its round. Crucible's finding sat in `5f2c7d8`'s hunk, so it counts against that round's line, whichever line it threatens:

```markdown
"Buying twice for the same order returns the first label and charges once." has had its fix round, and crucible found a second gap on it, so build has stopped patching it.

- **Finding**  `src/shipping/buy.ts:41` — a retry after a ShipCo timeout buys a second label; caused by `5f2c7d8`.
- **Survivors on this line**  `src/shipping/buy.ts:38 attempts < 3 → attempts < 4 — does a fourth attempt charge again?`

Does "Buying twice for the same order returns the first label and charges once." cover a retry after a timeout, where ShipCo may already have charged?
```

The answer keeps the line's wording, so it lands in the ticket's Decisions and the build carries on:

```markdown
- 2026-10-28 Q: Does "Buying twice for the same order returns the first label and charges once." cover a retry after a timeout? → A: Yes; a retry looks the label up by order before buying.
```

## The escalation

Asked in session once the body is updated, every unchecked step in one message, before the pull request goes ready:

```markdown
One Verify step on #57 wasn't run, so the pull request stays a draft until you rule on it:

- **ShipCo outage shows "Shipping is unavailable, try again"** — the sandbox has no way to force a 503. Can the reviewer check it by hand with `SHIPCO_BASE_URL=http://localhost:9 pnpm dev`, or should it run somewhere first?

Hand-back list — open after its one fix round, threatens no behaviour line, stops nothing:

- `src/shipping/client.ts:22` — a ShipCo response over 1 MB is read whole; `a3d81e0` capped the body but a chunked response skips the cap.
```

## The session comment

```markdown
### Build — 2026-10-28

**Units**  `b7d3f10` buy and store a label · `e1a90c4` replay a purchase and survive outages
**Vet**  crucible: 1 behaviour finding fixed in `5f2c7d8`, 1 with no line fixed in `a3d81e0`, 3 scratch tests pruned · verify: 2 of 3 passed, 1 left for the reviewer
**Hand-back**  `src/shipping/client.ts:22` chunked responses skip the body cap
**PR**  #57
**Resume**  nothing — complete
```

A run that filled its window instead ends `**Resume**  unit 2 of 2, from b7d3f10`.
One that ended with no ruling ends `**Resume**  awaiting a ruling on Verify step 3, the ShipCo outage — #57 stays a draft`.
