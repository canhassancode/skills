---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

## Procedure

1. Run `/grilling` for the interview loop, second-brain sweep, and capture-at-close.
2. Run `/domain-modeling` for domain work — challenge against the glossary, sharpen fuzzy language, stress-test with scenarios, cross-reference against code, update `CONTEXT.md` inline, and offer ADRs.

## Four-pass discipline — must complete before declaring the plan ready

Conversational grilling alone is not sufficient. Before declaring a plan ready (whether for `/to-spec`, `/to-tickets`, `ready-for-human`, or `ready-for-agent`), the grilling agent must complete all four passes below. Skipping any pass and falling back to _"the user said it only touches X"_ is the failure mode this discipline exists to prevent.

### 1. Trace, don't list

For every flow the work touches, follow the request path through the code. Enumerate **every branch** encountered (if/else, switch, polymorphic dispatch). Each branch is a candidate surface for the change. In a shallow-module codebase there is no useful module boundary to list — you trace by behaviour, not by directory.

### 2. Consumer search

For every field, type, endpoint, or behavioural contract being changed, grep for reads. Do not trust _"this is only consumed by X"_ from the user — verify by search. Record what you found in the brief's `Key interfaces` section.

### 3. CONTEXT.md sketch if missing

If the repo has no `CONTEXT.md` (or no entry in `CONTEXT-MAP.md` for the area being touched), do not proceed blind. Sketch one for the area in scope — the relevant contexts, the relevant terms, the relevant consumers — using [CONTEXT-FORMAT.md](../domain-modeling/CONTEXT-FORMAT.md). The sketch lives at the root after the session and grows session-over-session.

### 4. Feature-flag / branch awareness

When reading code, explicitly look for feature flags, A/B branches, env-conditional code paths, and config-driven dispatch. These hide parallel implementations that look like a single path on the surface. The classic failure: grilling identifies "one resolver" because the second resolver is gated behind `if (flag)` two lines up.

Each pass produces concrete output in the brief — named surfaces (with branches noted), named consumers (verified by grep), and any new terms added to `CONTEXT.md`. A brief without these is not ready, regardless of how complete the conversation felt.

### Build-bound: shape criteria toward the gauntlet's seam

When the grill is **build-bound** — heading for `/to-spec`, `/to-tickets`, or `ready-for-agent` — the four passes above have already found the real seams; use them to shape the emerging acceptance criteria so the eventual ticket is gauntlet-fit **by construction**, not repaired later at Preflight. Two checks, both drawn from the trace:

- every criterion names an outcome observable at an **Edge the running system serves** (the surface the gauntlet's QA stage drives), not a unit-only boundary — if the outcome has no served Edge, the shaping act is to **grow one** (a grow-the-seam prep decision), never to lower the seam;
- nothing the ticket must deliver lives entirely in `protectedPaths` (config, test-runner files) — work that does is not gauntlet-drivable and routes to `/implement`.

This shaping applies **only** to build-bound grills. Never force scenario shape onto a grill routing to a **proposal**, an **ADR**, or **nothing** — those are not build work and owe no served Edge. The mechanical check stays out of this skill: `ticket-lint` at Preflight is the backstop; the shaping is the judgement only the trace can supply.

## At close — route the output

A grill is a _thinking_ artifact; it is **not** automatically a spec. Forcing every session toward `/to-spec` is the most common way this flow breaks. At the end, **recommend** where this grill should go based on what it actually produced, then let the user choose — never auto-route. Present the menu with a reasoned recommendation:

| Route                | When it fits                                                        | Next step                                                      |
| -------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Spec**             | a build spec for implementers, broken into slices                   | `/to-spec` → tracker as `ready-for-agent` (then `/to-tickets`) |
| **Proposal**         | an argued recommendation for a decision-maker (your manager, a stakeholder) | `/to-proposal` → tracker as `ready-for-human`                  |
| **Tickets (direct)** | small, well-understood work — skip the spec ceremony                | `/to-tickets`                                                  |
| **ADR**              | a hard-to-reverse decision worth recording next to the code         | write the ADR in-repo                                          |
| **Nothing**          | the grill aligned your own head; no artifact needed                 | —                                                              |

Say which you'd pick and why (_"this reads like a proposal for a decision-maker, not a build-spec — I'd route it to `/to-proposal`"_), then act on the user's call. `/to-spec` and `/to-tickets` publish `ready-for-agent` by construction — the planning lane does **not** route through `/triage`, which now handles _inbound_ work only (bugs from users, collaborator drafts, stale tickets).

The route **is** the closing step. This is the densest-decision skill in the set, and the artifact the route names — the spec, the proposal, the tickets, the ADR — is where the reasoning has to land. "Nothing" is a real route, not a place to defer to.
