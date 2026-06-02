---
name: ingest
description: Process a source (pasted transcript, clipped article, notes) into the Obsidian Library wiki — write a summary, update entity/concept pages, reconcile categories, update index and log. Use to file a meeting/video/article into the second brain.
---

# Ingest

Processes one source into the Library (`~/Obsidian/Library/`). Read `~/Obsidian/Library/CLAUDE.md` (the wiki schema), `~/Obsidian/CONTEXT.md`, and `~/Obsidian/CONVENTIONS.md` (formatting) first.

## Source types

- **Consumed source** (`ingest` verb) — an article, transcript, meeting, notes. Pasted text or a file in `Library/raw/`.
- **Grilling session** (`grill` verb) — a `/grill-with-docs` or `/grill-me` design conversation, handed in at session close. The "source" is the **live conversation**, summarised in-place (no `raw/` file). Captures Hassan's *own* reasoning, so log it with the `grill` verb for provenance. **No raw, ever** — a grilling transcript is a Class A minefield of paths/SHAs/code.

## Pipeline

1. **Read** the source — a consumed source (pasted text / `Library/raw/` file), or, in **session mode**, the grilling-conversation summary handed in.
2. **Classify** — domain (Personal/Employment/Ventures) + sensitive?
3. **Content-class gate** — extract Class B; never write Class A (code, SHAs, PII, secrets).
   - Raw storage: Class B clipped article stays in `raw/`; pasted text is ephemeral unless told to keep; **sensitive source and every grilling session → no raw, ever**.
4. **Discuss takeaways** with Hassan (stay involved; one source at a time).
5. **Employment review gate** — Employment-domain derived notes are shown for approval **before** write. Personal/Ventures write through.
6. **Reconcile & write** — read `index.md` first; update existing `entities/` and `concepts/` pages and link the new source, or create new pages only when none fit. Flag contradictions on touched pages. Keep the `sources/` summary lean (raw covers the detail).
7. **Update** `index.md`; append `log.md` (`## [YYYY-MM-DD] ingest|grill | <title>`).
8. **Report** which pages changed.

## The derived note is not an abstraction

It keeps full Class B fidelity — intent, who-said-it, decisions, reasoning, learnings — and drops **only** Class A artefacts. Never reduce to platitudes.

## Related
`/ask` — query what you've ingested · `/inbox` — routes sources here · `/grill-with-docs`, `/grill-me` — hand in a grilling session at close
