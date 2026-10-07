# 1. Example pass

## Playback

```markdown
Today a customer submits a basket and the API creates an order straight away; nobody takes payment at checkout, and someone settles each order by hand later. You want a card payment at checkout, so an order only exists once it's paid for.

**This pass settles:** what a successful card and a declined card do to checkout. Refunds and saved cards go to Unresolved with their routes.

Is that the problem as you see it?
```

## A round

One scenario, one question, one recommendation. The fact it rests on sits under it; options appear only when the choices genuinely differ.

```markdown
**A declined card, then a second card**

Sam's first card is declined. They stay on the basket, try a second card, and it goes through. Today the order row is written when the basket is submitted, before any payment call — so Sam's declined attempt already has an order behind it.

❓ **When Sam's second card goes through, should an order exist for the declined attempt at all?**

**Impact** - 11 of the 80 declined checkouts in the last 30 days retried and succeeded (`payment_attempts`); each left a declined order beside a live one, and support can't tell which is the customer's.

➡️ **No — no order until a payment succeeds.** A declined payment isn't an order, and reusing the row leaves a total and a status that disagree the moment the basket changes between attempts.

↳ `apps/api/src/checkout/basket.ts:88` writes the order at submit, before any payment call.
```

## A challenge

An answer that clashes with the code, `CONTEXT.md` or something said earlier goes back with the evidence before it is recorded.

```markdown
You said a decline should keep the order as `pending` so support can see it — but earlier you said no order exists until payment succeeds, and `orders.status` has no `pending` today (`apps/api/src/orders/order.ts:14`). Those can't both hold.

❓ **Which wins: no order until payment, or a pending order support can see?**

➡️ **No order until payment; support reads declines from `payment_attempts`.** It already records every attempt (`apps/api/src/payments/attempt.ts:9`), so support loses nothing.
```

An anecdote is not evidence: "I've never seen it fail" keeps the safeguard and asks for the count.

## A term

A word goes into `CONTEXT.md` only as its own question, in the user's own words first.

```markdown
❓ **Add to CONTEXT.md: "Payment attempt — one charge tried against one card for one basket; a basket can have many"?**

➡️ **Yes** — you've used "attempt" all session, and it's the word `payment_attempts` already uses.
```

## An ADR

Only when domain-modeling's three criteria hold, and always its own question.

```markdown
❓ **Record an ADR: "An order exists only after a successful payment"?** It's hard to reverse once refunds hang off orders, a future reader will wonder why orders aren't written at submit, and it beat a real alternative (one row per basket).

➡️ **Yes.** I'll show you the text before writing it.
```

## Design — only for an interface the change adds or reshapes

````markdown
Checkout asks one module whether a basket may become an order. The provider sits behind it, so checkout never learns which provider is in use.

```ts
interface PaymentGate {
  charge(basketId: BasketId, card: CardToken): Promise<ChargeResult>
}

type ChargeResult =
  | { kind: 'paid'; orderId: OrderId }
  | { kind: 'declined'; reason: DeclineReason }

const result: ChargeResult = await paymentGate.charge(basket.id, card)
```

❓ **Should `charge` write the order itself on `paid`, or leave that to checkout?**

➡️ **The gate writes it** — the order and its payment land together or not at all.

↳ `apps/api/src/orders/orderRepo.ts:12` lets any caller `create` an order today.
````

## The close

```markdown
Here's what we've agreed:

- No order exists until a payment succeeds; a declined attempt leaves only a `payment_attempts` row.
- Sam stays on the basket after a decline, with the reason shown.
- `PaymentGate.charge` writes the order on `paid`.

Unresolved: refunds (pass), saved cards (pass).

Is that our shared understanding? If so, I'll update the ticket to `ready-to-cut` — here's the body.
```

# 2. Example routes

A question no fact settles and no choice moves is not argued — it leaves the round as a route.

**Something to see.** The user can't judge the declined-card screen from prose:

```markdown
❓ **Want a prototype of the declined-card screen?** Three variants on a throwaway branch, switchable in the browser.

➡️ **Yes** — the screen is the decision, and words have already produced three pictures of it.
```

**A premise to run.** The walk finds the build would depend on something reading can't prove:

```markdown
The webhook handler assumes the provider retries a failed delivery. Its docs say "at least once" but not for how long, and our handler drops anything older than an hour (`apps/api/src/payments/webhook.ts:31`).

➡️ **Spike it before we agree the handler** — a throwaway branch that fails a webhook in the provider's sandbox and logs every retry for a day. Its log becomes the premise's probe.
```

In Unresolved:

- **The declined card screen's shape** — **Route: prototype**. Owner: the operator. Artefact: `prototype/decline-screen`, linked from the pass comment.
- **How long the provider retries a webhook** — **Route: prototype** (spike). Owner: a sub-agent. Artefact: `prototype/webhook-retries` and its log, cited as the premise's probe.

# 3. Alignment Artefacts

## Captured ticket (multiple passes)
Alignment passes aren't always one session, in a bigger plan, create an artefact ticket in the following shape:

### Alignment ticket title

A good title contains the thing you would grep for: a component, endpoint, file, flag, or number. A title that names a feeling is not a ticket.

| Bad | Good | What changed |
|---|---|---|
| "Login broken" | "Session cookie not set on Safari 17 after OAuth redirect" | Symptom → observable fact with scope |
| "Fix bug in checkout" | "Order total ignores discount code when cart has >1 item" | Names the input condition and wrong output |
| "Improve performance" | "Reduce `/search` p95 latency from 4.2s to under 500ms" | Vague wish → measurable target |
| "Investigate DB issue" | "Postgres connection pool exhausted under 50 concurrent uploads" | Names the mechanism, not the vibe |
| "Add feature for users" | "Allow users to export transaction history as CSV" | Names actor, action, artifact |
| "Refactor auth" | "Split `AuthService` into token issuance and session lookup" | Says what the split is |
| "Customer complained about emails" | "Welcome email arrives 6 hours late (SendGrid queue backlog)" | Complaint → reproducible behaviour |
| "Update dependencies" | "Upgrade React 17 → 18, remove `ReactDOM.render` calls" | Names the version and the follow-on work |
| "Make UI nicer" | "Align invoice table to design tokens; row height 48px" | Replaces taste with a spec |
| "Something wrong with API" | "`POST /v1/refunds` returns 500 when `amount` is null" | Endpoint, trigger, status code |

### Labels

- needs-alignment (ongoing alignment captured in ticket)
- needs-info (blocked and needs answers from someone/something external to user and agent)
- ready-to-propose (a yes is owed outside the room, before the work can be cut)
- ready-to-cut (ready to hand off to `/cut`)
- ready-to-build (ready to build straight from alignment ticket)

### Body

Plain words, as in [TICKET.md](../cut/TICKET.md): a section with nothing in it is left out, except `Unresolved`.

```markdown
**Passes: N · Verdict: < aligned | fog | dropped | thin > · Destination: < tickets | proposal | ADR | nothing > · Verified against:** `<sha>`

> If dropped: the reason, in one paragraph, at the top.

# Background context
[ One paragraph on the why; a placeholder's triage notes fold in here at pass 1. ]

# Problem statement
[ One paragraph, told through one concrete scenario. ]

# Scenarios

1. **[ A name in plain words. ]** [ Who, the starting state, the trigger ] — [ what they observe ].

# Acceptance criteria

Each decided by `[ command ]`.

- [ ] C1 · S1 · `[ witness ]`: [ what the witness shows ].

# Decisions

- **[ The choice, as a sentence. ]** [ Why, in one line — the rejected alternative named where it helps. ]

# Premises

- [ A fact about code, data or runtime ] — [ `path:line @ sha` with its symbol, or the command and its output ].

# Interfaces

| name | signature | owned | consumed |
| --- | --- | --- | --- |

# Boundaries

**Always** · **Ask first** · **Never**

# Out of scope

1. [ What, and why not. ]

# Axes

**Axes:** n decision · n N/A

| axis | mark | note |
| --- | --- | --- |
| happy path | | |
| limits | | |
| failure | | |
| misuse | | |
| concurrency and idempotency | | |
| permissions | | |
| observability | | |
| rollback | | |
| cost | | |

# Unresolved
[ None, or one **Route** per entry — research · prototype · task · pass · decide — with its owner and where the artefact lands. ]

**Next:** [ `/cut`, `/propose`, `/build`, `/align <ref>`, or `stop`. ]
```

### Comment (passes)
- If alignment proceeds past one session and requires more depth, each comment adds what was discovered in that pass.
- If body already exists on ticket created by someone else or some other route, place the body as is in a comment.
- Each pass is minimal, showing only what was discovered, the body is the alignment truth.

```markdown
**Pass N · Verdict: < aligned | fog | dropped | thin >**

# Aligned on
[ Concise bullet point list ]

# Outstanding
[ What is still open, and what stops this moving to ready-to-cut or ready-to-build ]

# Sources
[ Research notes, prototype branches, spikes from this pass ]
```

## Placeholder (written by `/triage`)

A raw line queued at `needs-alignment`: the body above, degenerate to three rows and no `Passes:` header. The first alignment pass folds the notes into Background and writes the header and the rest of the rows over it.

```markdown

# Background context
[ One paragraph on how the work arrived, and why it is worth a pass. ]

# Problem statement
[ One paragraph on what is wanted or wrong, in the words of whoever brought it. ]

# Triage notes
[ What triage established: the category, where the codebase already stands, any prior rejection surfaced, and the route when one was named. ]

```
