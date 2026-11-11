# Spec

A spec is its ticket's body: a parent's on the parent ticket, a child's on its own. Two shapes: a **parent** holds what its children share; a **child** is one capability for one session. Status never goes in a spec. The label holds it, because hand-kept status fields drift.

## Child

```markdown
Parent: #40 · Branch: `feat/buy-a-label`, draft PR #43

## Goal
Buy a label for a chosen rate and store its tracking number on the order.

## Context
ShipCo: POST /v2/labels. Needs: Quote rates (merged). Follows the pattern in `src/payments/charge.ts`.

## Interface
- `Shipping.buyLabel(orderId, rateId): Result<Label, BuyLabelError>`
- `Carrier.purchaseLabel({ rateId, idempotencyKey }): Result<CarrierLabel, CarrierError>`

## Behaviour
- A valid rate buys a label and stores the tracking number on the order.
- Buying twice for the same order returns the first label and charges once.
- An expired rate is reported as rate_expired and nothing is stored.
- ShipCo being down is reported as unavailable after retries and nothing is stored.

## Out of scope
Label PDF rendering.

## Done when
`pnpm test src/shipping` and `pnpm test:contract carrier` pass.

## Verify
- Start: `pnpm dev` (port 3000), sandbox key from `SHIPCO_API_KEY`
- POST /api/orders/123/label `{"rateId":"r_1"}` → 201 with a tracking number; GET /api/orders/123 shows it
- /orders/123 shows "Tracking: SC…" under Shipping

## Decisions
- 2026-10-21 Q: Retry a 409 from ShipCo? → A: No; it means the label exists, so fetch it (spike).
```

## Parent

```markdown
## Goal
Customers buy a ShipCo label at checkout and see tracking on their order.

## Out of scope
Returns, customs, multi-parcel shipments, a second carrier.

## Shape
- One module, `shipping`; the app calls only `createShipping`.
- `shipping` reaches ShipCo only through the `Carrier` interface.
- Each child adds its methods to `Shipping` and `Carrier`; no new interfaces.

## Rules every child follows
- The API key comes from `SHIPCO_API_KEY` and is never logged.
- Anything that charges money is idempotent per order.
- Webhooks are signature-checked before anything else is read.

## Journeys
1. A customer checks out and sees a tracking number.
2. ShipCo reports delivery and the order shows delivered.

## Children, in build order
- [ ] #41 Quote rates — show delivery options and prices for a basket.
- [ ] #42 Buy a label — buy a label for a chosen rate and store its tracking number.

## Decisions
- 2026-10-20 Q: Do ShipCo webhooks arrive signed? → A: Yes, HMAC-SHA256 (spike).
```

## Rules for each section

- **Header line** (child only): the parent, then the branch and its draft PR. A child that touches more than one repo names each repo's branch there, and the merge order when one repo must merge first: ``Parent: #40 · Branch: api `feat/buy-a-label`, draft PR #43 · admin `feat/buy-a-label` · Merge order: admin, then api``.
- **Behaviour**: one plain sentence per line, observable through the interface from outside, with no codes or numbering. On code, each line becomes a locked test title word for word, so editing one later means a relock; on prose or settings, crucible reviews the diff against it. An "always" or "never" line becomes a property.
- **Interface**: empty until step 5 approves it; `none — prose or settings` when the medium has none. A parent fixes shape, not signatures.
- **Context**: the files, the existing pattern to copy and the merged siblings it needs. Name a pattern by its file, not by its name.
- **Out of scope**: every area the conversation touched and left out, each with a reason if it isn't obvious.
- **Done when**: commands that run, not prose.
- **Verify** (child only): how a person sees it working on the running app — the start command with the credentials it needs, then each request or page and what it shows. Agreed with the user, because `/build` runs these steps without reading the code and leaves an unchecked box for any it can't. A child with nothing to run writes `none — <why>`.
- **Rules** (parent only): cross-cutting requirements every child inherits without restating them.
- **Journeys** (parent only): one or two end-to-end paths, written once at parent level.
- **Children** (parent only): a name and one line each, in build order. `/cut` turns them into tickets with their behaviour lines and adds each one's ticket to its line, so the list is the parent's checklist; each child's interface and tests come back through `/align` just before it is built.
- **Decisions**: dated `Q → A`, newest last, the route in brackets where one answered it. A decision that outlives the feature becomes an ADR.
- **Claims** (Context, Decisions and a parent's Rules; not Behaviour, whose lines become test titles): every fact about the world that the spec rests on carries where it was checked and on how many cases, on its line, as `checked on: <where>, <how many>` — a measured number, who calls a thing, which other repo reads a field, what state the rows are in, what a supplier sends back. A number chosen in the room, such as a budget or a cap we set, is a decision and carries nothing. A fact stated with nothing that checked it, however confidently, is not checked. Before writing the spec, check each claim against its **target**, where the change will actually run, such as the exact artifact CI installs, the production data or the live supplier; a local copy of any of them is a **stand-in**:
  - Checked on the target by a route or a tool: record it with where. The claim was approved; don't re-open how it was checked.
  - Checked on a stand-in for a different target, such as a scratch install or a local database: a subagent checks it again on the target before it is recorded; reading the value from the target's own files, such as the pinned version's installed defaults, checks it. The target's answer replaces it, and the stand-in's appears nowhere in the ticket. Your reply gives the target's answer, where it was checked, and what it replaced.
  - Target is production: a subagent checks it, always, through a read-only route from step 1's list. Its brief names that route and forbids any write and reading `.env`, `.mcp.json` or any config. A database read asks for a count or a grouped count before rows, caps any row read with a `LIMIT`, and runs `explain_query` before `execute_sql` where the route offers both. The ticket records counts and shapes, never a customer's row. Neither you nor it opens, greps or globs config files: find the route in the session's tools or in the docs, never in config. Your reply names the route and the reads the subagent ran or tried, with what came back.
  - A claim about every case — "always", "never", "all", "the format is" — is checked on a sample, never on one case: `/spike`'s sample rule. `checked on: live supplier, 2 cars` is recorded as it is, so a thin check reads as thin.
  - Another repo reads what changes: a subagent greps each sibling repo for the field, value or endpoint and the claim records the hits as `repo/file:line`, or `none found in <repos>`.
  - A supplier response the tests will fake: Context names the recorded response by its path, one for each case the behaviour lines tell apart. `/tester` builds the fake from it and invents none.
  - No route to its target, or the subagent can't reach it: record it as `unchecked` on its line and carry on. Don't ask the user for the fact; step 1 already told them the route is missing.

## Evidence

- Small specs win: shorter, well-scoped issues are the ones that get merged (Sayagh, Dec 2025); focused prompts beat long ones on every model tested (Chroma, Jul 2025).
- Goal, context, constraints and a runnable done-when: OpenAI's Codex guidance and Claude Code best practices.
- Verify on the running app: Anthropic's long-running harness found agents marked features done without testing them end to end, and checking as a user "dramatically improved" results; tests with fakes at ports pass while nothing is wired in.
- Behaviour and boundaries, not patterns: repo context files cut success by 0.5–2 points (Gloaguen et al., Feb 2026).
- The Decisions log: Spec Kit's Clarifications and OpenAI's ExecPlan Decision Log.
- Locking just in time, not up front: in this library's own trackers, 25% of later slices had their contract change after a sibling merged, and 14% were dropped, folded or re-cut (forge and skills issues, measured 2026-10-27).
