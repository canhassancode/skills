# Spec

A spec is a ticket's body. A **parent** holds what its children share. A **child** is one tracer bullet that fits one fresh `/build` session. Status never goes in a spec: the label holds it, because hand-kept status fields drift.

`/align` writes the spec once, at the end, from the conversation. It is a synthesis, not a fresh interview (Pocock's to-spec). Before you show it, re-read it against what the user actually said. Later steps tend to soften precise answers such as ordering guarantees, negative requirements and numeric defaults, so keep them word for word.

## Child

```markdown
Parent: #40 · Blocked by #41

## What to build
Buy a label for a chosen rate and store its tracking number on the order.

## Acceptance criteria
- [ ] A valid rate buys a label and stores the tracking number on the order.
- [ ] Buying twice for the same order returns the first label and charges once.
- [ ] An expired rate is reported as rate_expired and nothing is stored.

## Seams
`createShipping` is the one seam, with ShipCo faked at the `Carrier` port. Prior art: `src/payments/payments.test.ts`.

## Verify
- Start: `pnpm dev` (port 3000), sandbox key from `SHIPCO_API_KEY`
- POST /api/orders/123/label `{"rateId":"r_1"}` → 201 with a tracking number; GET /api/orders/123 shows it
- /orders/123 shows "Tracking: SC…" under Shipping

## Out of scope
Label PDF rendering.

## Decisions
- A 409 from ShipCo means the label exists: fetch it, don't retry (spike).
```

## Parent

```markdown
## Goal
Customers buy a ShipCo label at checkout and see tracking on their order.

## Out of scope
Returns, customs, multi-parcel shipments, a second carrier.

## Shape
- One module, `shipping`; the app calls only `createShipping`. That is the seam every child tests at.
- `shipping` reaches ShipCo only through the `Carrier` port.

## Rules every child follows
- The API key comes from `SHIPCO_API_KEY` and is never logged.
- Anything that charges money is idempotent per order.

## Journeys
1. A customer checks out and sees a tracking number.
2. ShipCo reports delivery and the order shows delivered.

## Children, in build order
1. Quote rates: show delivery options and prices for a basket.
2. Buy a label: buy a label for a chosen rate and store its tracking number. Blocked by 1.

## Decisions
- ShipCo webhooks arrive signed with HMAC-SHA256 (spike).
```

## Rules for each section

- **Header line** (child): the parent and what blocks it. A child that spans repos names each repo and the merge order: `Repos: admin, then api`.
- **Acceptance criteria**: one plain sentence each, observable from outside, with no codes. They are what the build tests and what crucible checks. A child has about six. An "always" or "never" criterion becomes a property test.
- **Seams**: as few as possible, ideally one, at the highest point that can see the behaviour. Prefer an existing seam to a new one. Name the prior-art test file. Confirm the seams with the user before the spec is written.
- **Verify** (child): how a person sees it working on the running app. Give the start command with the credentials it needs, then each request or page and what it shows. A criterion that a fake can't prove, because a value has to reach a real process, a socket, a file or a page, has a Verify step that shows it. A child with nothing to run writes `none — <why>`.
- **Out of scope**: every area the conversation touched and left out, each with its reason when that isn't obvious.
- **Decisions**: the answers the spec rests on, one line each, with the route in brackets where a spike or research settled it. A decision that outlives the feature becomes an ADR.
- **Shape, Rules, Journeys** (parent): the seams and the cross-cutting requirements every child inherits without restating them, plus one or two end-to-end paths.
- **Children** (parent): one line each in build order, with blocking edges. `/cut` turns them into tickets.
- **Claims**: a fact about where the change will run (a row count, who calls a thing, what a supplier returns) carries `checked on: <where>, <how many>`. Check it read-only on the real target, never on a local stand-in, with a subagent. One you can't reach is marked `unchecked`. A claim about every case is checked on a sample, never on one case.

## Evidence

- Small specs win: shorter, well-scoped issues are the ones that get merged (Sayagh, Dec 2025); focused prompts beat long ones on every model tested (Chroma, Jul 2025).
- Synthesise, don't re-interview, and prefer the fewest, highest seams: Pocock's to-spec.
- Verify on the running app: Anthropic's long-running harness found agents marked features done without testing them end to end. On brigade#136 every test passed on fakes while the key never reached the app (ADR-0013).
