---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. `/receive` picks it up.

## Where to save

- **If `~/Obsidian/` exists** — write to `~/Obsidian/Handoffs/<YYYY-MM-DD-HHMM>-handoff.md`. The vault is the store because it is the only surface constant across every machine; the handoff is transport through it, not a page in it. **Wikilink the pages the next session will need** (`[[Perivale Apartment - Hoover Building]]`, `[[GymBuddies]]`, …) as plain pointers. The handoff is **Class B working context** — never write Class A (secrets, credentials, customer PII, verbatim proprietary source). File paths + SHAs are fine here (B-private) and often exactly what the next session needs.
- **If the vault is absent** — fall back to `mktemp -t handoff-XXXXXX.md`.

Read the file before you write to it.

## Content

Suggest the skills the next session should use. Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs) — reference them by path or URL instead.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

### Discarded as noise

Write the dead ends down: hypotheses ruled out, approaches tried and abandoned, and why each was dropped. This is the section that earns the handoff — it is the one thing `/compact` cannot express, and without it the next session re-walks paths this one already closed.

## Lifecycle

A handoff is **transient** — consumed once. It lives in `Handoffs/` until `/receive` resumes it, and `/receive` **deletes** it. There is no archive. An un-received handoff is open work, so `Handoffs/` non-empty always means something real is open.
