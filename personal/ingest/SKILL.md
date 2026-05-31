---
name: ingest
description: Process a source (pasted transcript, clipped article, notes) into the Obsidian Library wiki — write a summary, update entity/concept pages, reconcile categories, update index and log. Use to file a meeting/video/article into the second brain.
---

# Ingest

Processes one source into the Library (`~/Obsidian/Library/`). Read `~/Obsidian/Library/CLAUDE.md` (the wiki schema) and `~/Obsidian/CONTEXT.md` first.

## Pipeline

1. **Read** the source (pasted text, or a file in `Library/raw/`).
2. **Classify** — domain (Personal/Employment/Ventures) + sensitive?
3. **Content-class gate** — extract Class B; never write Class A (code, SHAs, PII, secrets).
   - Raw storage: Class B clipped article stays in `raw/`; pasted text is ephemeral unless told to keep; **sensitive source → no raw, ever**.
4. **Discuss takeaways** with Hassan (stay involved; one source at a time).
5. **Employment review gate** — Employment-domain derived notes are shown for approval **before** write. Personal/Ventures write through.
6. **Reconcile & write** — read `index.md` first; update existing `entities/` and `concepts/` pages and link the new source, or create new pages only when none fit. Flag contradictions on touched pages. Keep the `sources/` summary lean (raw covers the detail).
7. **Update** `index.md`; append `log.md` (`## [YYYY-MM-DD] ingest | <title>`).
8. **Report** which pages changed.

## The derived note is not an abstraction

It keeps full Class B fidelity — intent, who-said-it, decisions, reasoning, learnings — and drops **only** Class A artefacts. Never reduce to platitudes.

## Related
`/ask` — query what you've ingested · `/inbox` — routes sources here
