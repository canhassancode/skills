---
name: eod-summary
description: Write today's End-of-Day Summary in the Obsidian second brain — record each Work Item's disposition (done / signed-off with reason / carried) so unfinished work rolls into tomorrow's brief. Use when wrapping up the day.
---

# EOD Summary

Writes `~/Obsidian/Journal/<YYYY-MM-DD>-summary.md` — the results of the day and the carry-forward signal. Read `~/Obsidian/CONTEXT.md` first for terms.

## When to run

End of the working day, after the day's work is done.

## Procedure

1. Open today's `~/Obsidian/Journal/<YYYY-MM-DD>-brief.md`.
2. For **each** Work Item, record a disposition with the user:
   - `done` — completed.
   - `signed-off (reason)` — deliberately dropped; the reason is **required**.
   - `carried` — untouched or partial; rolls into tomorrow's brief by default.
3. Capture anything worth keeping: decisions made, learnings (offer to `/ingest` substantial ones into the Library), and new captures into `~/Obsidian/Inbox/`.
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

- Never write Class A content (code, SHAs, PII, secrets) — see `CONTEXT.md`.
- Link back to today's brief (`[[<YYYY-MM-DD>-brief]]`) so the day is one connected unit.

## Related

- `/morning-brief` — consumes the Carried section tomorrow.
- `/ingest` — file substantial learnings into the Library.
