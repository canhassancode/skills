---
name: morning-brief
description: Compile today's Morning Brief in the Obsidian second brain — carried-forward items, open tracker issues, triaged Inbox, and Profile grounding, sectioned by domain. Use at the start of the day, or when no brief exists for today.
---

# Morning Brief

Compiles `~/Obsidian/Journal/<YYYY-MM-DD>-brief.md` — the day's cross-domain index of intended work. Read `~/Obsidian/CONTEXT.md` (domain model) and `~/Obsidian/CONVENTIONS.md` (file formatting) first.

## When to run

Start of day, or when prompted (the `SessionStart` hook nudges only when today's brief is missing). If a brief already exists for today, do not regenerate it — open it and ask which items to pick up.

## Open with one question

Before compiling, ask once: *"Quick chat to prioritise, or shall I just compile and hand it over?"* Default is **compile-and-present** (the brief's job is a fast, scannable index — don't force an interview). On "chat", ask a **bounded** few (≤3–5) prioritisation questions, then compile.

## Self-heal the previous day

Before compiling today, check the most recent prior day: if it has a `-brief.md` but **no `-summary.md`**, the day was never closed. Offer to run `/eod-summary` for it **first** (so carry-forward is correct), then compile today. The Loop checks its own integrity each morning.

## Inputs to compile from

1. **Carried-forward items** — yesterday's `<YYYY-MM-DD>-summary.md`: every Work Item not `done` or `signed-off (reason)` rolls forward by default.
2. **Open tracker issues** — for active repos, query the repo's resolved tracker for open issues assigned to you (GitHub: `gh issue list --assignee @me --state open`; Linear: your assigned open issues via the Linear MCP), plus any repo-specific queries. Each becomes an issue-backed Work Item.
3. **Triaged Inbox** — if `~/Obsidian/Inbox/` is non-empty, note it and offer to run `/inbox` first; promoted captures become Work Items.
4. **Open handoffs** — if `~/Obsidian/Handoffs/` is non-empty, an agent session was handed off but never resumed. Surface each and offer `/receive` (un-received handoffs are open work, like carried items).
5. **Profile grounding** — `~/Obsidian/Profile/overview.md` (Active focus) to order and prioritise.

## Output

`~/Obsidian/Journal/<YYYY-MM-DD>-brief.md`, ISO-dated. Sectioned by **Domain** (Personal / Employment / Ventures). Under each, the Work Items as checkboxes.

```markdown
---
type: brief
date: <YYYY-MM-DD>
---

# <YYYY-MM-DD> — Morning Brief

## Personal
- [ ] <plain task — non-coding, no tracker>

## Employment
- [ ] [[#142]] <issue-backed — execute> · <one-line context>

## Ventures
- [ ] <raw-software — needs grilling> → `/grill-with-docs` then `/to-issues`
```

## Work Item flavours

- **issue-backed** — links a tracker issue (`[[#142]]`); execute directly.
- **raw-software** — no issue yet; routes through `/grill-with-docs` → `/to-prd` → `/to-issues`.
- **plain task** — non-coding life/admin; just check it off. The Journal is its only tracker.

## Rules

- Link Work Items to their project hub (`[[Brushfeed]]`, `[[Acme]]`) so the hub's backlinks become a timeline of work.
- Never write Class A content (secrets, credentials, customer PII, verbatim proprietary source) into the brief — see `CONTEXT.md`. Paths/SHAs are B-private, not Class A.
- Keep it scannable: the goal is reconstructing "what's open, what to touch today" in under 30 seconds.
- The brief is the day's **plan**, not a live tracker — write it once and don't babysit the checkboxes. The day's living record is `<YYYY-MM-DD>-log.md` (written by `/log`); `/eod-summary` reconciles the two at close. An unchecked box at EOD is not failure; the log says what actually happened.

## Related

- `/log` — the living record the day's work is captured into.
- `/eod-summary` — consolidates the log and sets carry-forward.
- `/inbox` — triages captures into Work Items before compiling.
