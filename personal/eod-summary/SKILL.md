---
name: eod-summary
description: Write today's End-of-Day Summary in the Obsidian second brain — record each Work Item's disposition (done / signed-off with reason / carried) so unfinished work rolls into tomorrow's brief. Use when wrapping up the day.
---

# EOD Summary

Writes `~/Obsidian/Journal/<YYYY-MM-DD>-summary.md` — the results of the day and the carry-forward signal. **Consolidates** today's daily log; it does not reconstruct the day from memory. Read `~/Obsidian/CONTEXT.md` (terms) and `~/Obsidian/CONVENTIONS.md` (formatting) first.

## When to run

End of the working day, after the day's work is done.

## The three-file model

The brief is the morning *plan*, the **log** (`<YYYY-MM-DD>-log.md`) is the living *record* written by `/log` through the day, and this summary is the *consolidation*. Each disposition should be backed by a real log entry with a reason — not a checkbox flipped from memory. A morning checkbox left unchecked is not failure; the log says what actually happened.

## Open with one question

Ask once: *"Shall I consolidate from today's log, or have you got a dump to add?"*

- **Consolidate** (default) — read today's log, reconcile it against the brief, and present a drafted disposition per item for confirmation. Don't interrogate item-by-item where the log already answers.
- **Dump** — the user adds how the day went on top of the log; merge it, then show the result for a quick confirm.

## Procedure

1. **Read the log** — `~/Obsidian/Journal/<YYYY-MM-DD>-log.md` (if it exists) and today's `<YYYY-MM-DD>-brief.md`.
2. **Reconcile** — for **each** brief Work Item, find the log entries that bear on it and derive a disposition + reason from them:
   - `done` — completed (the log says what and why).
   - `signed-off (reason)` — deliberately dropped; the reason is **required** (pull it from the log).
   - `carried` — untouched or partial; rolls into tomorrow's brief by default (note where it got to, per the log).
   - For an item the log doesn't cover, *then* ask — that gap is exactly what the live log is meant to remove.
3. **Surface ingest material** — the log's decisions and learnings are pre-captured raw material; offer to `/ingest` substantial ones into the Library (this is where the "worth keeping?" offer finally has real content, not a checkbox flip). Route any new captures into `~/Obsidian/Inbox/`.
4. If `~/Obsidian/Inbox/` has items, nudge: offer to run `/inbox`.
5. Update `~/Obsidian/Profile/overview.md` Active focus if priorities shifted (lint: trim completed focus into the relevant concept page).

## Output

```markdown
---
type: summary
date: <YYYY-MM-DD>
---

# <YYYY-MM-DD> — EOD Summary

## Done
- [x] <item> — <one-line result>

## Signed off
- ~~<item>~~ — <required reason>

## Carried → next brief
- [ ] <item> — <where it got to>

## Notes / decisions
- <decision or learning>
```

## The carry-forward rule

Anything not `done` or `signed-off (with a recorded reason)` carries forward by default. Nothing vanishes silently — dropping an item always costs a reason. Tomorrow's `/morning-brief` reads the `Carried` section as its first input.

## Rules

- Never write Class A content (secrets, credentials, customer PII, verbatim proprietary source) — see `CONTEXT.md`. Paths/SHAs are B-private, not Class A.
- Link back to today's brief and log (`[[<YYYY-MM-DD>-brief]]`, `[[<YYYY-MM-DD>-log]]`) so the day is one connected unit.

## Related

- `/log` — the living record this consolidates.
- `/morning-brief` — consumes the Carried section tomorrow.
- `/ingest` — file substantial learnings into the Library.
