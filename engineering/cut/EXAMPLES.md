# Cut examples

The parent is #40, *ShipCo integration*, with its spec in its body.

## The set, before publishing

```markdown
**ShipCo integration (#40) → 4 children, in build order**

1. **Quote rates**: show delivery options and prices for a basket.
   - A basket with a UK address shows ShipCo's rates, cheapest first.
   - An address ShipCo can't deliver to shows no rates and says why.
   - Verify: /checkout with basket 7 lists ShipCo rates.

2. **Buy a label**: buy a label for the chosen rate and store its tracking number on the order. Blocked by 1.
   - A valid rate buys a label and stores the tracking number on the order.
   - Buying twice for the same order returns the first label and charges once.
   - Verify: POST /api/orders/123/label → 201; /orders/123 shows the tracking number.

3. **Track a shipment**: the order page shows the tracking number and ShipCo's latest status. Blocked by 2.
4. **Mark delivered**: a signed delivered webhook moves the order to delivered. Blocked by 2.

"Shipments table" was a layer, so it is folded into Buy a label, the first child to store a shipment.

❓ **Q1 · Granularity**: four children, each one build session. Right size?
➡️ Yes.

❓ **Q2 · Edges**: 3 and 4 both wait only on 2, so they can be built in either order. Right?
➡️ Yes.

❓ **Q3 · Publish**: all four at `ready-to-build`?
➡️ Yes.
```

## The parent's Children after the cut

```markdown
## Children, in build order
- [ ] #41 Quote rates: show delivery options and prices for a basket.
- [ ] #42 Buy a label: buy a label for the chosen rate and store its tracking number on the order.
- [ ] #43 Track a shipment: the order page shows the tracking number and ShipCo's latest status.
- [ ] #44 Mark delivered: a signed delivered webhook moves the order to delivered.
```

## A re-cut

```markdown
**#42's build stopped after two sessions**: idempotency needs a stored key, which takes Buy a label past one session.
➡️ Split it into Buy a label (#42, criteria 1 and 3) and Buy once per order (new, criterion 2, blocked by #42). #43 and #44 then wait on the new child.
```
