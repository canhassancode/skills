---
name: pickup
description: Verification pass for a ready-for-human ticket. Open the named surfaces and consumers in the agent brief, confirm they still match current code, then route to /tdd, /diagnose, or a targeted re-grill. Use when picking up a ticket labelled ready-for-human, or when a session opens on an issue already in that state.
---

# Pickup

When a session opens on a `ready-for-human` ticket, do **not** reflexively re-run `/grill-with-docs`. The agent brief is the contract — verify it against current code, then execute.

## Why this skill exists

`ready-for-human` means two things:

1. The spec is locked (intent has been grilled)
2. The four-pass discipline in `/grill-with-docs` was completed (surfaces traced, consumers grepped, branches enumerated, `CONTEXT.md` updated)

A full re-grill at pickup is wasted cost — it re-opens resolved questions. But triage runs at the issue tracker level, and the codebase may have drifted since the brief was written. Pickup is a **verification pass** against that brief — not a re-grilling cycle.

If you find yourself wanting to re-grill at pickup, that's a signal that either (a) the brief is genuinely incomplete (a triage discipline failure — escalate) or (b) you're slipping back into the old reflex (resist).

## Procedure

### 1. Read the agent brief

Note the **surfaces touched** and **consumers affected** named in the `Key interfaces` section. These are the verifiable manifest. If neither is present in any form, the brief is incomplete — skip to *Brief is incomplete* below.

### 2. Verify named surfaces

For each surface the brief names, open the code and confirm:

- The surface still exists at the contract level (function signature, type shape, endpoint, resolver registration)
- Its current behaviour matches the brief's *current behavior* section
- No new branches (feature flags, env gates, A/B switches) have appeared that the brief doesn't account for

### 3. Verify named consumers

For each consumer the brief names, grep for the read pattern and confirm it still matches what the brief expects. If new consumers have appeared, that's drift.

### 4. Decide

- **All match** → invoke the right execution skill:
  - **Bug ticket** → `/diagnose` (which will also confirm the bug still reproduces)
  - **Enhancement ticket** → `/tdd`
- **Drift on a named surface or consumer** → run a **targeted re-grill** scoped only to the drift. Do not run full `/grill-with-docs`. Update the brief inline with what you find, then route to `/tdd` or `/diagnose`.
- **Brief is incomplete** (omits surfaces or consumers that should clearly have been named — typically meaning the four-pass discipline didn't run) → escalate to full `/grill-with-docs`. This is a triage discipline failure, not a pickup-time concern; flag it to the maintainer.

## What pickup is NOT

- **Not a full grilling session.** Skip the design tree walk. Intent is locked.
- **Not a re-evaluation of intent.** If you find yourself wanting to question *what* should happen rather than *whether the code still matches the brief*, you're re-grilling. Stop.
- **Not a discovery process.** If the brief feels too thin to verify, that's a brief bug — escalate, don't paper over.

## Relationship to `ready-for-agent`

Agents do **not** run pickup. The agent brief is their contract; verification is a human-only step. If a `ready-for-agent` brief feels under-specified at pickup time, that's a triage discipline bug — the four-pass discipline in `/grill-with-docs` should be applied *more* strictly for `ready-for-agent` than for `ready-for-human`, because agents have no judgment to course-correct mid-stream.
