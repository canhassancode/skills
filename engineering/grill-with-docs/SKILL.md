---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

## Procedure

1. Run `/grilling` for the interview loop, second-brain sweep, and capture-at-close.
2. Proceed with the domain-specific work below.

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
| **Proposal** | an argued recommendation for a decision-maker (the manager, a stakeholder) | `/to-proposal` → Notion |
| **Issues (direct)** | small, well-understood work — skip the PRD ceremony | `/to-issues` |
| **ADR** | a hard-to-reverse decision worth recording next to the code | write the ADR in-repo |
| **Library only** | durable reasoning, no outbound work | capture below |
| **Nothing** | the grill aligned your own head; no artifact needed | — |

Say which you'd pick and why (*"this reads like a proposal for the manager, not a build-spec — I'd route it to a Notion proposal"*), then act on the user's call. `/triage` only enters the picture on the PRD/Issues branches — it's the GitHub-queue step, not a mystery skill.

## Log the session (if `~/Obsidian/` exists)

Mandatory closing step, not optional: append one line to today's daily log via the `/log` convention — what was grilled, the route chosen at close, the sharpest decision and *why*, and any blocker. This is the densest-decision skill in the set; never let the reasoning evaporate. Skip silently if the vault is absent.
