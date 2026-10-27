# Examples

One feature throughout: customers buy a ShipCo shipping label at checkout.

## Tier

```markdown
Today checkout takes payment and an operator buys each label by hand in ShipCo's dashboard. You want checkout to buy the label and show tracking on the order.

**Tier: bigger, and foggy.** It's four capabilities (rates, label, tracking, cancel), and nobody here knows whether ShipCo's sandbox sends signed webhooks — the tracking child rests on it.

❓ **Spike the webhook signing first, then write a parent spec?**

➡️ **Yes.** Tracking's whole design changes if the webhooks aren't signed; a 20-minute spike settles it before anything is written.
```

## Red team

```markdown
**Red team: shrink to rates and labels; tracking later.**

- ShipCo's tracking page already shows status, and order emails link to it — `src/emails/dispatched.tsx:22`.
- 3% of orders had a "where is my parcel" ticket last quarter (`support_tickets`, 41 of 1,380).
- Tracking needs a public webhook endpoint, the app's first; nothing yet verifies inbound signatures.

For, despite the above: operators spend about 2 hours a day buying labels by hand, and that's rates and labels alone.

❓ **Go with all four, shrink to rates and labels, or no-go?**
```

## A round

One scenario, one question, one recommendation. The fact it rests on sits under it.

```markdown
**Buying twice**

Sam clicks Pay, the request times out, and they click again. Both requests reach `buyLabel` for the same order and the same rate.

❓ **Should the second request buy a second label?**

➡️ **No — return the first label and charge once.** ShipCo charges per label, and a duplicate costs £6.50 plus a void request.

↳ `src/checkout/pay.ts:41` retries on timeout with no idempotency key today.
```

## A challenge

An answer that clashes with the code, `CONTEXT.md` or something said earlier goes back with the evidence before it is recorded.

```markdown
You said a failed label purchase should still mark the order as shipped so the operator sees it — but earlier you said an order shows shipped only once it has a tracking number, and `orders.status` already has `awaiting_label` (`src/orders/order.ts:14`). Those can't both hold.

❓ **Which wins: shipped only with a tracking number, or shipped as soon as payment succeeds?**

➡️ **Only with a tracking number; a failed purchase leaves `awaiting_label`.** The operator's queue already reads that status.
```

An anecdote is not evidence: "ShipCo never goes down" keeps the retry and asks what an outage would cost.

## A term

```markdown
❓ **Add to CONTEXT.md: "Label — one paid ShipCo shipment for one order; an order has at most one live label"?**

➡️ **Yes.** You've said "label" all session, and it's the word ShipCo's API uses.
```

## An ADR

Only when domain-modeling's three criteria hold, and always its own question.

```markdown
❓ **Record an ADR: "Labels are bought at checkout, not at dispatch"?** It's hard to reverse once tracking hangs off it, a future reader will ask why we pay before packing, and it beat a real alternative (buy at dispatch, when the parcel is weighed).
```

## An interface

One interface at a time: the code, one caller, the error kinds.

````markdown
```ts
buyLabel(orderId: OrderId, rateId: RateId): Promise<Result<Label, BuyLabelError>>

type BuyLabelError = { kind: 'rate_expired' } | { kind: 'unavailable' } | { kind: 'rejected'; detail: string }
```

Caller, `src/checkout/pay.ts`:

```ts
const label = await shipping.buyLabel(order.id, basket.rateId)
if (!label.ok && label.error.kind === 'rate_expired') return requote(order)
```

❓ **Approve `buyLabel`?**

➡️ **Yes.** It returns errors as values, like `quoteRates`, and each error kind maps to one behaviour line.
````

## The tests

```markdown
`/tester` wrote 4 locked tests, all red for the right reason:

| Behaviour | File | Red because |
|---|---|---|
| A valid rate buys a label and stores the tracking number on the order. | `src/shipping/shipping.acceptance.test.ts` | not implemented |
| Buying twice for the same order returns the first label and charges once. | same | not implemented |

Interface gaps: none.

❓ **Lock them?**
```

## A ticket body

The body never grows past this. A child's body is the same without the children.

```markdown
Customers buy a ShipCo label at checkout and see tracking on their order.

Spec: [docs/specs/shipco-integration.md](…) · draft PR #40

- [ ] #41 Quote rates
- [ ] #42 Buy a label
```

## A session comment

One per session, carrying only what moved.

```markdown
**Session 2: Buy a label**

Moved: interface approved (`a1b2c3d`), 4 tests locked (`d4e5f6a`), label → `ready-to-build`.

Decisions
- Q: Retry a 409 from ShipCo? → A: No; it means the label exists, so fetch it (spike).
- Q: Store the label PDF? → A: Out of scope; link only.

Next: `/build #42`
```
