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

## At close — route the output

A grill is a _thinking_ artifact; it is **not** automatically a spec. Forcing every session toward `/to-spec` is the most common way this flow breaks. At the end, **recommend** where this grill should go based on what it actually produced, then let the user choose — never auto-route. Present the menu with a reasoned recommendation:

| Route                | When it fits                                                        | Next step                                                      |
| -------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Spec**             | a build spec for implementers, broken into slices                   | `/to-spec` → tracker as `ready-for-agent` (then `/to-tickets`) |
| **Proposal**         | an argued recommendation for a decision-maker (Pete, a stakeholder) | `/to-proposal` → Notion                                        |
| **Tickets (direct)** | small, well-understood work — skip the spec ceremony                | `/to-tickets`                                                  |
| **ADR**              | a hard-to-reverse decision worth recording next to the code         | write the ADR in-repo                                          |
| **Library only**     | durable reasoning, no outbound work                                 | capture below                                                  |
| **Nothing**          | the grill aligned your own head; no artifact needed                 | —                                                              |

Say which you'd pick and why (_"this reads like a proposal for Pete, not a build-spec — I'd route it to a Notion proposal"_), then act on the user's call. `/to-spec` and `/to-tickets` publish `ready-for-agent` by construction — the planning lane does **not** route through `/triage`, which now handles _inbound_ work only (bugs from users, collaborator drafts, stale tickets).

## Log the session (if `~/Obsidian/` exists)

Mandatory closing step, not optional: append one line to today's daily log via the `/log` convention — what was grilled, the route chosen at close, the sharpest decision and _why_, and any blocker. This is the densest-decision skill in the set; never let the reasoning evaporate. Skip silently if the vault is absent.
