# Examples

One feature throughout: customers buy a ShipCo shipping label at checkout.

## Tier

```markdown
Today checkout takes payment, and an operator buys each label by hand in ShipCo's dashboard. You want checkout to buy the label and show tracking on the order.

**Tier: bigger, and foggy.** It's four capabilities (rates, label, tracking, cancel), and nobody knows yet whether ShipCo's sandbox sends signed webhooks. The tracking child depends on that, so I've sent it to a spike and I'll grill around it.

Routes: read-only Postgres MCP ✓, ShipCo sandbox key ✓, production logs ✗ (nothing in this session reaches them).

❓ **Bigger and foggy, so a parent spec cut into children?**
➡️ Yes.
```

## A round

The whole frontier at once, each question with its options and a recommendation.

```markdown
❓ **Q1 · Buying twice**: Sam clicks Pay, the request times out, and they click again. Both requests reach checkout for the same order and rate. Should the second request buy a second label?

➡️ No: return the first label and charge once. ShipCo charges £6.50 per label, and `src/checkout/pay.ts:41` retries on timeout with no idempotency key today.

---

❓ **Q2 · A rate that has expired**: Sam picks Royal Mail at £6.50, leaves the tab open over lunch, and clicks Pay an hour later. ShipCo rates expire after 30 minutes (`docs/shipco.md:18`). What should Sam see?

➡️ Ask Sam to pick a rate again, and buy nothing. The other option, buying at the new rate, charges Sam a price they never saw.

---

❓ **Q3 · Seams**: test everything through `createShipping`, with ShipCo faked at the `Carrier` port, the way `src/payments/payments.test.ts` does payments. One seam?

➡️ Yes. It is the one place checkout calls, so every criterion is visible there.
```

An answer of "not sure" to Q2 stays open. Say who would know (here, whoever owns checkout) and ask them.

## A challenge

```markdown
You said a failed label purchase should still mark the order as shipped. Earlier you said an order shows shipped only once it has a tracking number, and `orders.status` already has `awaiting_label` (`src/orders/order.ts:14`). Those can't both hold.

❓ **Which wins: shipped only with a tracking number, or shipped as soon as payment succeeds?**
➡️ Only with a tracking number, so a failed purchase leaves `awaiting_label`. The operator's queue already reads that status.
```

## Where each line came from

Shown under the spec. The yes on the spec and on each of your calls come in one round.

```markdown
**You said**
- A valid rate buys a label and stores the tracking number on the order.
- An expired rate asks Sam to pick a rate again, and nothing is stored.

**Checked**
- Buying twice for the same order returns the first label and charges once. ShipCo answers a repeat with the first label (spike, 12 orders).

**My call**
❓ **Q1 · Outage wait**: when ShipCo is down, Sam sees "unavailable" after three tries, about 6 seconds. Is that right?
➡️ Yes.

❓ **Q2 · The spec**: write it to #42 as above, at `ready-to-build`?
➡️ Yes.
```

## A session comment

One per session, carrying only what moved. A session that stops before the spec ends in a Resume line.

```markdown
**Session 1: ShipCo integration**

Decided
- ShipCo webhooks arrive signed with HMAC-SHA256 (spike).
- Labels are bought at checkout, not at dispatch (ADR-0004).

Open
- Which of the four capabilities ship first.
- What Sam sees when a rate has expired: waiting on whoever owns checkout.

**Resume**  next round: ship order, then the expired-rate answer. `/clear`, then `/align #40`
```
