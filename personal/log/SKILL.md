---
name: log
description: Append a timestamped entry to today's daily log in the Obsidian second brain — what happened, what was decided and why, what's blocked. Use when closing out a unit of work, recording a decision or blocker mid-day, or as the closing step of another skill (grill, tdd, diagnose, triage, commit, pr).
---

# Daily Log

Appends to `~/Obsidian/Journal/<YYYY-MM-DD>-log.md` — the living record of the day between the morning brief (the plan) and the EOD summary (the consolidation). Append-only; never rewrite earlier entries. Read `~/Obsidian/CONVENTIONS.md` (formatting) first if creating the file.

## The three-file model

- **brief** — the morning *plan*. Write-once, not babysat. Unchecked boxes are not failure.
- **log** — the living *record*. This file. Accrues all day, captures the WHY in the moment.
- **summary** — the EOD *consolidation*. `/eod-summary` reads this log and reconciles it against the brief.

The log exists so the WHY is captured when it happens, not reconstructed from memory at 6pm.

## When to run

- **Manual** — `/log <free text>`: an interstitial note (a decision made away from the keyboard, a hallway conversation, a blocker hit). Capture must be near-zero friction — one line, no ceremony.
- **Skill-exit (the spine)** — another skill calls this as a mandatory closing step. A decision, a routed grill, a finished slice, a hit blocker — each appends one line on close. This is not optional; the documented failure mode is "wrap-up left to discretion never happens."
- **Brief item changes disposition** — when a Work Item is done/blocked mid-session, append a line *with the reason*. That reason is the context the brief's checkbox can't hold and the material `/ingest` later wants.

## Entry format

One timestamped bullet per entry. Get the time with `date +%H:%M`.

```
- HH:MM — <what happened>. <decision + why, if any>. [blocked: <what / on whom>] · [[Hub]]
```

Keep it to one scannable line. Link the project hub (`[[Carpata]]`, `[[Brushfeed]]`) so the hub's backlinks become a timeline. Drop the `[blocked: …]` clause unless there's a blocker; drop the hub if there's no obvious one.

## Procedure

1. Resolve today's date and the current time (`date +%F`, `date +%H:%M`).
2. If `~/Obsidian/Journal/<date>-log.md` doesn't exist, create it from the template below (header links today's brief).
3. Append the entry under the existing entries, in time order. Never edit or reorder earlier lines.

## Output

```markdown
---
type: log
date: <YYYY-MM-DD>
---

# <YYYY-MM-DD> — Daily Log

Living record for the day. Plan: [[<YYYY-MM-DD>-brief]].

- 09:12 — Standup: Pete reset the week to the search dashboard. Carried the QA triage to await Michael. · [[Carpata]]
- 11:40 — Grill on embed-widget partial refunds → routed to a Notion proposal. Decided order-scoped session token. [blocked: scope, on Pete] · [[Carpata]]
- 14:05 — Filed confirmation statement. · [[Brushfeed]]
```

## Confidentiality

- **Allowed at full fidelity (B-private):** working context, decisions, rationale, and — unlike the old rule — **file paths and commit SHAs**. The log is private and encrypted; the connective detail (which file, which commit) is what makes it useful to future-you. These are stripped only when content is *published outward* (e.g. a Notion proposal), which is an audience rule, not a secrets rule.
- **Never written (Class A):** live secrets, credentials, tokens, customer PII, customer financial data, verbatim proprietary source. Pseudonymise customer identity — `[[MB-DealerGroup-1]]` "large MB group, price-sensitive", never the legal entity, account number, or contact.

## Related

- `/morning-brief` — the plan this log records against.
- `/eod-summary` — consolidates this log at day's end (reconciles brief vs log, surfaces ingest material).
- `/ingest` — durable learnings logged here can be filed into the Library.
