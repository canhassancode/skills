---
name: ask
description: Answer a question from the Obsidian second brain — route to the right wiki (Library for the world, Profile for Hassan), read its index, drill into the relevant pages, and synthesise an answer with citations, falling back to raw notes only when needed. Use to query your stored learnings, articles, notes, people, and self-model.
---

# Ask

Queries the read-heavy corpus at minimal token cost. That corpus is **two LLM Wikis** with the same index-first access pattern (see `~/Obsidian/CONTEXT.md`):

- **Library** (`~/Obsidian/Library/`) — subject = *the world*: consumed content, references, learnings. Schema: `~/Obsidian/Library/CLAUDE.md`.
- **Profile** (`~/Obsidian/Profile/`) — subject = *Hassan*: self-model, key people, goals, career, health. Schema: `~/Obsidian/Profile/CLAUDE.md`.

If you file an answer back as a page, conform to `~/Obsidian/CONVENTIONS.md`.

## Procedure

1. **Route.** Question about Hassan, a person, or a contact ("who is X", "what's their email") → **Profile**. Question about consumed content or the outside world → **Library**. If unsure or it spans both, check both indexes — they're cheap.
2. **Read the index first** (do **not** grep raw notes first):
   - Library → `index.md`, then drill into `sources/` / `entities/` / `concepts/`.
   - Profile → `overview.md` for the pointer; people and layer pages are **filename-addressable**, so go straight to `People/<Name>.md`, `goals.md`, `career.md`, etc. when the name is known.
3. **Fallback only if needed** — when the synthesised page lacks the detail, drill into that wiki's raw layer:
   - Library → the source's `raw/` transcript.
   - Profile → the Domain notes it summarises (`Personal/`, `Employment/`, `Ventures/`, `Journal/`) via its down-links. Employment notes are Class B working context — surface to Hassan, never re-export.
4. Answer with **citations** (links to the pages used).
5. If the answer is itself worth keeping (a comparison, a synthesis, a discovered connection), offer to file it back as a new page **in the wiki it belongs to** (Library or Profile) so explorations compound.

## Why index-first

Both wikis are pre-synthesised, so most questions are answered from a couple of dense pages — not by re-reading raw material. That is the minimal-token mechanism. Reach for the raw layer only for long-tail detail.

## Related
`/ingest` — add sources · `/inbox` — triage captures into the Library
