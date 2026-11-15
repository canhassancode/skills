# Build examples

The ticket is #42, *Buy a label*, a child of #40 *ShipCo integration*.

## The pull request

```markdown
## Summary

Buy a ShipCo label for the chosen rate and store its tracking number on the order. Closes #42.

## Acceptance criteria

| Criterion | Test | Result |
|---|---|---|
| A valid rate buys a label and stores the tracking number on the order. | `shipping.test.ts` | green |
| Buying twice for the same order returns the first label and charges once. | `shipping.test.ts` | green |
| An expired rate is reported as rate_expired and nothing is stored. | `shipping.test.ts` | green |

Full suite: 412 passed.

## Verify

- [x] POST /api/orders/123/label `{"rateId":"r_1"}` → 201, tracking `SC48213` (output below)
- [x] /orders/123 shows "Tracking: SC48213" under Shipping (`verify/order-123.png`)
- [ ] A ShipCo outage shows "Shipping is unavailable, try again". Not run in session because the sandbox can't force a 503. To check: `SHIPCO_BASE_URL=http://localhost:9 pnpm dev`, then buy a label on /orders/123.

## Decided limits

- Label PDF rendering is out of scope (spec).

## Hand-back

- `src/shipping/client.ts:22` — a chunked response over 1 MB skips the body cap; still open after its fix round.
```

The unchecked outage step keeps this pull request a draft. Rewrite the Summary and Decided limits from the diff as it stands after the last fix. A sentence left over from an earlier round is what reviewers send back most.

## A Resume line

The last line of the pull request body when the window fills:

```markdown
Resume: criteria 1–2 green and committed (`b7d3f10`); next is criterion 3, the expired rate, then Verify.
```

## A stop

Posted on the ticket; the ticket moves to `needs-alignment`.

```markdown
### Build stopped — 2026-10-28

**Criterion**  "Buying twice for the same order returns the first label and charges once."
**Why it can't hold**  ShipCo's 409 answer carries no `createdAt`, so a refetched label can't equal the first one field for field.
**Proposal**  compare `id` and `trackingNumber` only.
**Green so far**  `b7d3f10`, pushed.
```
