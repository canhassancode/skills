---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

## Procedure

1. Before exploring, ask: "Fan-out via subagents (scout + ask + researcher) or linear?"
   Launch accordingly. If subagents unavailable, proceed linearly.

2. Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## Second-brain awareness (if `~/Obsidian/` exists)

If `~/Obsidian/CLAUDE.md` is absent, skip this section silently — do not block.

When the vault is present, the grilling compounds with the second brain:

- **Open with a sweep** — run an index-first `/ask` on the session's stated topic to surface prior grillings, ingested articles, and Profile focus that bear on it. One sweep on the topic, plus a targeted re-query when a *specific* concept comes up — never a blanket dump (it adds noise and breaks `/ask`'s retrieval-cost discipline).
- **Authority order** — the repo's `CONTEXT.md`/ADRs are **canon**; the vault is *supplementary input*. A Library page is a snapshot of what was true when captured, so a vault page that **contradicts current code is a flag to surface** (*"your `Stripe Checkout` concept says webhook-as-truth, but this resolver reads the session — which is right?"*), never a fact to trust over the live code.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

## Four-pass discipline — must complete before declaring the plan ready

Conversational grilling alone is not sufficient. Before declaring a plan ready (whether for `/to-prd`, `/to-issues`, `ready-for-human`, or `ready-for-agent`), the grilling agent must complete all four passes below. Skipping any pass and falling back to *"the user said it only touches X"* is the failure mode this discipline exists to prevent.

### 1. Trace, don't list

For every flow the work touches, follow the request path through the code. Enumerate **every branch** encountered (if/else, switch, polymorphic dispatch). Each branch is a candidate surface for the change. In a shallow-module codebase there is no useful module boundary to list — you trace by behaviour, not by directory.

### 2. Consumer search

For every field, type, endpoint, or behavioural contract being changed, grep for reads. Do not trust *"this is only consumed by X"* from the user — verify by search. Record what you found in the brief's `Key interfaces` section.

### 3. CONTEXT.md sketch if missing

If the repo has no `CONTEXT.md` (or no entry in `CONTEXT-MAP.md` for the area being touched), do not proceed blind. Sketch one for the area in scope — the relevant contexts, the relevant terms, the relevant consumers — using [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md). The sketch lives at the root after the session and grows session-over-session.

### 4. Feature-flag / branch awareness

When reading code, explicitly look for feature flags, A/B branches, env-conditional code paths, and config-driven dispatch. These hide parallel implementations that look like a single path on the surface. The classic failure: grilling identifies "one resolver" because the second resolver is gated behind `if (flag)` two lines up.

Each pass produces concrete output in the brief — named surfaces (with branches noted), named consumers (verified by grep), and any new terms added to `CONTEXT.md`. A brief without these is not ready, regardless of how complete the conversation felt.

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Don't couple `CONTEXT.md` to implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

## At close — route the output

A grill is a *thinking* artifact; it is **not** automatically a PRD. Forcing every session toward `/to-prd` is the most common way this flow breaks. At the end, **recommend** where this grill should go based on what it actually produced, then let the user choose — never auto-route. Present the menu with a reasoned recommendation:

| Route | When it fits | Next step |
|---|---|---|
| **PRD** | a build spec for implementers, broken into slices | `/to-prd` → GitHub (then `/to-issues`, `/triage`) |
| **Proposal** | an argued recommendation for a decision-maker (Pete, a stakeholder) | `/to-proposal` → Notion |
| **Issues (direct)** | small, well-understood work — skip the PRD ceremony | `/to-issues` |
| **ADR** | a hard-to-reverse decision worth recording next to the code | write the ADR in-repo |
| **Library only** | durable reasoning, no outbound work | capture below |
| **Nothing** | the grill aligned your own head; no artifact needed | — |

Say which you'd pick and why (*"this reads like a proposal for Pete, not a build-spec — I'd route it to a Notion proposal"*), then act on the user's call. `/triage` only enters the picture on the PRD/Issues branches — it's the GitHub-queue step, not a mystery skill.

## Capture into the Library (if `~/Obsidian/` exists)

Orthogonal to the route above — a grill can become a PRD *and* still be worth keeping. The repo docs (`CONTEXT.md`/ADRs) are the code-side output. The brain-side output is the synthesis worth retrieving later. At the **end** of the session, offer once: *"Capture this grilling into the Library?"* On yes, hand a session summary to `/ingest` (session mode → a `grill`-sourced Library page).

- These two outputs stay **decoupled**: capture the decisions and rationale. File paths and SHAs are **B-private** (not Class A) — fine to keep where they aid recall, but the brain page should still **stand alone** rather than depend on repo links that rot, and you must still drop true Class A (verbatim proprietary source, secrets, customer PII; pseudonymise customer identity).
- Never auto-capture — not every session is worth keeping, and the human-in-the-loop offer matches the Employment review gate.
- Skip silently if the vault is absent.

## Log the session (if `~/Obsidian/` exists)

Mandatory closing step, not optional: append one line to today's daily log via the `/log` convention — what was grilled, the route chosen at close, the sharpest decision and *why*, and any blocker. This is the densest-decision skill in the set; never let the reasoning evaporate. Skip silently if the vault is absent.
