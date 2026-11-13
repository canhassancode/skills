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

A technical choice: one scenario, one question, one recommendation. The fact it rests on sits under it.

```markdown
**Buying twice**

Sam clicks Pay, the request times out, and they click again. Both requests reach `buyLabel` for the same order and the same rate.

❓ **Should the second request buy a second label?**

➡️ **No — return the first label and charge once.** ShipCo charges per label, and a duplicate costs £6.50 plus a void request.

↳ `src/checkout/pay.ts:41` retries on timeout with no idempotency key today.
```

## An open round

What someone will see is the user's to say first. No recommendation, no options; the fact still sits under it.

```markdown
**A rate that has expired**

Sam picks Royal Mail at £6.50, leaves the tab open over lunch, and clicks Pay an hour later. ShipCo no longer honours that price.

❓ **What should Sam see?**

↳ ShipCo rates expire after 30 minutes (`docs/shipco.md:18`); checkout doesn't check today.
```

An answer of "not sure, whatever you think" stays open: say who would know, here whoever owns checkout, and ask them.

## Where each line came from

Shown before anything is locked. Plain words, one line each, nothing to approve under the first two headings.

```markdown
**You said**
- A valid rate buys a label and stores the tracking number on the order.
- An expired rate asks Sam to pick a rate again and nothing is stored.

**Checked**
- Buying twice for the same order returns the first label and charges once. ShipCo answers a repeat with the first label (spike, 12 orders).

**My call, needs your answer**
- ShipCo being down is reported as unavailable after three tries. You haven't said how long Sam should wait; three tries is about 6 seconds.

❓ **Is 6 seconds of waiting right when ShipCo is down, or should Sam see the message sooner?**
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
4 tests in 1 file. 4 fail as they should. Nothing needs you.

**Your call**
- nothing

**These tests won't catch**
- Checkout never calling the label purchase: the tests buy a label directly, not through Pay. Verify step 1 catches it.

**What each test checks**

`src/shipping/shipping.acceptance.test.ts`
- A valid rate buys a label and stores the tracking number on the order.
  Tried with: Sam paying for an order with a Royal Mail rate quoted a minute ago. Should show: one label bought, and its tracking number on the order.
- Buying twice for the same order returns the first label and charges once.
  Tried with: Sam clicking Pay twice after a timeout. Should show: the same label both times, and ShipCo charged once.

Typecheck: `npm run typecheck` — clean
Gaps: none

Validator: 4/4 green against throwaway code, no blockers. Locked at `d4e5f6a`.
```

## A ticket body

The body is the spec, in [references/spec.md](references/spec.md)'s shape. Before align closes, it holds whatever arrived: triage's placeholder, or `/cut`'s goal line and draft behaviour lines. Align replaces it whole, except Decisions: each settled answer is appended there the moment it is settled, and the spec keeps every line already there.

## The draft pull request

Build's [pull request](../build/EXAMPLES.md#the-pull-request), filled in with what align knows at the lock. Nothing is ticked: build ticks each step it runs.

```markdown
## Summary

Buy a ShipCo label for the chosen rate and store its tracking number on the order. Closes #42.

## Behaviour

| Behaviour | Test | Result |
|---|---|---|
| A valid rate buys a label and stores the tracking number on the order. | `shipping.acceptance.test.ts` | red |
| Buying twice for the same order returns the first label and charges once. | `shipping.properties.test.ts` | red |

Locked at `d4e5f6a`.

## Verify

- [ ] POST /api/orders/123/label `{"rateId":"r_1"}` → 201 with a tracking number
- [ ] /orders/123 shows the tracking number under Shipping
- [ ] A ShipCo outage shows "Shipping is unavailable, try again"

## Decided limits

- Label PDF rendering is out of scope (spec).
- A 409 from ShipCo fetches the existing label instead of retrying (spec Decisions, 2026-10-21).
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
