---
name: ask
description: Answer a question from the Obsidian second brain — read the Library index, drill into the relevant pages, and synthesise an answer with citations, falling back to raw transcripts only when needed. Use to query your stored learnings, articles, and notes.
---

# Ask

Queries the Library (`~/Obsidian/Library/`) at minimal token cost. Read `~/Obsidian/Library/CLAUDE.md` for the schema.

## Procedure

1. Read `Library/index.md` to find the relevant pages (do **not** grep raw transcripts first).
2. Drill into the 1–3 most relevant `sources/` / `entities/` / `concepts/` pages.
3. **Fallback only if needed:** if the synthesised pages lack the specific detail and the source's `raw/` transcript exists, read it to extract the answer — including parts Hassan never personally reviewed.
4. Answer with **citations** (links to the pages used, which link to `raw/`).
5. If the answer is itself worth keeping (a comparison, a synthesis, a discovered connection), offer to file it back as a new Library page so explorations compound.

## Why index-first

The wiki is pre-synthesised, so most questions are answered from a couple of dense pages — not by re-reading many raw sources. That is the minimal-token mechanism. Reach for `raw/` only for long-tail detail.

## Related
`/ingest` — add sources · `/inbox` — triage captures into the Library
