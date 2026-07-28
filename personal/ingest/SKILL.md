---
name: ingest
description: Process a source — article, video, or book — into the Obsidian Library wiki — write a summary, update entity/concept pages, reconcile categories, update the index. Also drains the top item from Inbox/. Use to file an article, a video, or a chapter into the second brain.
---

# Ingest

Processes one source into the Library (`~/Obsidian/Library/`). Read `~/Obsidian/Library/CLAUDE.md` (the wiki schema), `~/Obsidian/CONTEXT.md`, and `~/Obsidian/CONVENTIONS.md` (formatting) first.

## Source types

- **Article** — a URL or clipped text. `WebFetch` the URL.
- **Video** — fetch the transcript, no download:

  ```sh
  uvx yt-dlp --skip-download --write-auto-sub --sub-lang en '<url>'
  ```

  The raw VTT carries YouTube's rolling captions, so **dedupe it before reading**: strip the WEBVTT header, cue timings and inline `<c>` tags, then drop each line that is a prefix of, or identical to, the line before it. Nothing to install — `uv` is present. If extraction fails on a missing JS runtime, `brew install deno`.
- **Book** — file the PDF into `Library/raw/`; `Read` handles PDFs directly. **Ingest once per chapter or sitting, not once per book.** One `entities/` page for the book; each pass writes into `concepts/`.

## Drain the Inbox

`/ingest` with no source given: read the **top item in `~/Obsidian/Inbox/`**. One item per invocation — the queue drains by being worked, not by being triaged. Three outcomes:

- **An external source** (article, video, book) — ingest it as one of the three types above.
- **One of Hassan's own ideas** — **stop. Do not ingest and do not bin.** Hand it to `/wayfinder` (foggy, needs a map) or `/grilling` (settles in one sitting), which file it into `~/Obsidian/Ideas/` and delete the Inbox item themselves. `/ingest` and `/wayfinder` are peer drains on the Inbox, not a pipeline — the capture's kind picks the drain. An idea is not an ingested item: the Library's subject is the world, so the only outcomes available here would be misfiling it or losing it.
- **Neither** — bin it.

## Pipeline

1. **Read** the source, per its type above.
2. **Classify** — domain (Personal/Employment/Ventures) + sensitive?
3. **Content-class gate** — extract Class B; never write Class A (secrets, credentials, customer PII and financial data, verbatim proprietary source). Paths/SHAs are B-private (keep where useful); pseudonymise customer identity, keep customer feedback.
   - Raw storage: a Class B clipped article or a book PDF stays in `raw/`; pasted text is ephemeral unless told to keep; a sensitive source gets **no raw, ever**.
4. **Propose, then judge.** Dedupe the source against what is already filed, then **propose**: which existing `concepts/` pages this touches, what each one gains or loses, and a drafted reconciliation for any contradiction. Hassan judges — accept, redirect, or reject. This step is the generation effect and the only thing separating this from a bookmarks folder. It is also the throttle: it trades daily volume for two or three considered sources a week, knowingly.
5. **Employment review gate** — Employment-domain derived notes are shown for approval **before** write. Personal/Ventures write through.
6. **Write** what was agreed — update the existing `entities/` and `concepts/` pages and link the new source; create a page only when none fits. Keep the `sources/` summary lean (raw covers the detail).
7. **Update `index.md`** with the new entry, **dated**. This is the only index.
8. **Report** which pages changed.

## Scale

`index.md` is read whole on every conceptual query, so it has a ceiling. Revisit its shape at **~115 entries** — the 200-line practical limit bites first at roughly 220 bytes an entry, long before any size limit does. Until then, one flat dated index.

## The derived note is not an abstraction

It keeps full Class B fidelity — intent, who-said-it, decisions, reasoning, learnings — and drops **only** Class A artefacts. Never reduce to platitudes.

## Related
`/ask` — query what you've ingested
