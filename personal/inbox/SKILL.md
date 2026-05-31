---
name: inbox
description: Triage the Obsidian second-brain Inbox — route each raw capture to a domain, the Library, a Work Item, the Profile, or the bin, with your approval. Use when the Inbox has accumulated, or when morning-brief/eod-summary flag pending captures.
---

# Inbox (Triage)

Empties `~/Obsidian/Inbox/`. Read `~/Obsidian/CONTEXT.md` first for the domain model.

## Procedure

1. List everything in `~/Obsidian/Inbox/`.
2. For **each** capture, propose one route and confirm with Hassan:

   | Route | When | Action |
   |---|---|---|
   | **Library** | a source (article, transcript, video) | hand to `/ingest` |
   | **Domain** | working material | file into `Personal/`, `Employment/<employer>/`, or `Ventures/<venture>/` |
   | **Work Item** | a task | add to today's brief — software → raw-software (needs `/grill-with-docs`); life/admin → plain task |
   | **Profile** | a fact about Hassan (goal, person, preference) | update `Profile/` (overview/concept/entity page) |
   | **Bin** | noise | delete |

3. Execute approved routes: move/create notes, update `index.md`/`log.md`/Profile/brief as needed.
4. Confirm the Inbox is empty.

## Rules

- Never write Class A content (code, SHAs, PII, secrets) — see `CONTEXT.md`.
- Link filed notes to their domain/project hub (`[[Brushfeed]]`, `[[Acme]]`).
- Batch obvious routes; slow down and ask on anything ambiguous.

## Related
`/ingest` · `/morning-brief` · `/eod-summary`
