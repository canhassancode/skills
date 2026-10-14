---
name: ask
description: Answer a question from the Obsidian second brain — route by the shape of the question (a named or factual lookup greps for the file; a fuzzy or conceptual question reads the Library index and drills), then synthesise an answer with citations. Use to query stored learnings, articles, notes, people, and self-model.
disable-model-invocation: true
---

# Ask

**The vault root.** Resolve it once, before anything else: `VAULT_ROOT` from the environment, defaulting to `~/Obsidian` when unset (`echo "${VAULT_ROOT:-$HOME/Obsidian}"`). Every vault path below is built from `$VAULT_ROOT`, as shorthand: shell state does not persist between commands, so substitute the resolved path it printed into every command and file path, never the bare `$VAULT_ROOT`. If that directory does not exist, stop and say so — never create a vault.

Queries the vault at minimal token cost. Two corpora, but they are **not** what decides the route:

- **Library** (`$VAULT_ROOT/Library/`) — subject = *the world*: consumed sources, references, learnings. It is the LLM Wiki: pre-synthesised, index-first. Schema: `$VAULT_ROOT/Library/CLAUDE.md`.
- **Profile / Personal** (`$VAULT_ROOT/Profile/`, `$VAULT_ROOT/Personal/`) — subject = *Hassan*: self-model, people, goals, career, health. Hand-edited, no index.

If you file an answer back as a page, conform to `$VAULT_ROOT/CONVENTIONS.md`.

## Route by query shape

The corpus does not decide the route — the **shape of the question** does.

- **Named or factual lookup** — "Youssef's email", "which solicitor", "what was the offer price". One fact, and it lives in exactly one file. **`grep -ril` for it first, then `Read` the hit.** Do not read an index; there is nothing to synthesise.
- **Fuzzy or conceptual discovery** — "have I read anything on agent memory", "what do I know about X". You do not know which file, and the answer is a synthesis across several. **Read `Library/index.md`, then drill** into `sources/` / `entities/` / `concepts/`.

When a question is both, do the lookup first — it is cheaper and it usually settles the question.

## The grep discipline

**`grep -ril` — filenames only — before any `Read`.** A bare `grep -r` on a broad term dumps matching lines from dozens of files and grep stops being the cheap step. Get the candidate filenames, pick, then `Read`.

Vary the search term rather than the search path: people are filed by role (`Financial Advisor`), by organisation (`NK Solicitors`) and by personal name interchangeably, so grep the **fact** ("mortgage", "@", "estate agent"), not the assumed filename.

## Surfaces to reach

`Library/` (external sources only) · `Personal/` · `Profile/people/` · `Ventures/Ideas/` · the P5M poster prompt · `Employment/<employer>/` working notes.

Employment notes are Class B working context — surface them to Hassan, never re-export.

## Answer

Answer with **citations** — links to the pages actually used. If the answer is itself worth keeping (a comparison, a synthesis, a discovered connection), offer to file it back as a page in the corpus it belongs to.

## Related
`/ingest` — add sources
