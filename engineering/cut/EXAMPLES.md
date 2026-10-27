# Cut examples

The parent is #40, *ShipCo integration*, with its spec at `docs/specs/shipco-integration.md` on `spec/shipco-integration`.

## A failed check

```markdown
❌ **Child 2, "Shipments table", is a layer.** Nothing a customer or caller sees changes when it merges; it only exists for "Buy a label".
➡️ Fold it into "Buy a label", which is the first child to store a shipment. The Children list loses one line.

❌ **No child completes journey 2** ("ShipCo reports delivery and the order shows delivered"). "Track a shipment" shows the tracking number but never reads a webhook.
➡️ Add "Mark delivered" after "Track a shipment": a signed `delivered` webhook moves the order to delivered.
```

## The set, before publishing

```markdown
**ShipCo integration (#40) → 4 children, in build order**

1. **Quote rates** — show delivery options and prices for a basket.
   - A basket with a UK address shows ShipCo's rates, cheapest first.
   - An address ShipCo can't deliver to shows no rates and says why.
   - ShipCo being down shows a retry message, not an empty list.

2. **Buy a label** — buy a label for the chosen rate and store its tracking number on the order. Blocked by 1.
   - A valid rate buys a label and stores the tracking number on the order.
   - Buying twice for the same order returns the first label and charges once.
   - An expired rate is reported as rate_expired and nothing is stored.

3. **Track a shipment** — the order page shows the tracking number and ShipCo's latest status. Blocked by 2.
   - …

4. **Mark delivered** — a signed delivered webhook moves the order to delivered. Blocked by 2.
   - …

Behaviour lines are drafts; each child's `/align` settles them with its interface and tests.
❓ Publish these four at `needs-alignment`?
```

## A child's body

```markdown
Buy a label for the chosen rate and store its tracking number on the order.

Parent: #40 · Spec: [docs/specs/shipco-integration.md](../blob/main/docs/specs/shipco-integration.md)
Blocked by #41

**Draft behaviour** — `/align` settles these before the build.
- A valid rate buys a label and stores the tracking number on the order.
- Buying twice for the same order returns the first label and charges once.
- An expired rate is reported as rate_expired and nothing is stored.
```

## The parent's body after the cut

```markdown
Customers buy a ShipCo label at checkout and see tracking on their order.

Spec: [docs/specs/shipco-integration.md](../blob/main/docs/specs/shipco-integration.md)

- [ ] #41 Quote rates
- [ ] #42 Buy a label
- [ ] #43 Track a shipment
- [ ] #44 Mark delivered
```

## The session comment

```markdown
**Session 2 — cut**

Moved: 4 children published at `needs-alignment` (#41–#44); "Shipments table" folded into Buy a label; "Mark delivered" added for journey 2 (`9c1e4b2`). Spec PR #39 marked ready.

Next: merge #39, then `/align #41`.
```

## A re-cut

```markdown
**#42's align split it:** idempotency needs a stored key, which makes "Buy a label" eight behaviour lines.
➡️ Split into "Buy a label" (#42, lines 1 and 3) and "Buy once per order" (new, line 2), blocked by #42; #43 and #44 now wait on the new child.
```
