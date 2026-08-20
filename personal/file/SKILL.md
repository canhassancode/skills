---
name: file
description: File a personal document or an atomic self-fact into the Obsidian vault — OCR a scan, write a matter note with its raws, or reconcile a fact into Profile. Also drains the top item from Inbox/. Use to file your own records (conveyancing, insurance, tax, vehicle) or a fact about yourself (a contact, a goal, a health note) — external reading is /ingest, not this.
---

# File

Files one **matter** — a document/record or an atomic self-fact — into a domain folder (`Personal/`, `Employment/`, `Ventures/`) or `Profile/`. The subject is **your own life**, not the world (that is `/ingest`). Read `~/Obsidian/CONTEXT.md` (the domain model) and `~/Obsidian/CONVENTIONS.md` (formatting) first.

## Intake types

- **Matter** — a received record about your life: a PDF, scan, email, or a bundle of them on one subject. The matter is the unit — **one note, many linked raws**: a 26-file conveyancing pack is one matter, not 26 notes; a single policy is a one-item matter. **OCR any scan on intake** so the raw is searchable before you synthesise — see [OCR.md](OCR.md).
- **Fact** — an atomic self-fact stated in text: a contact ("advisor's email is X"), a goal ("targeting bioinformatics"), a health note, an achievement.

## Drain the Inbox

`/file` with no target: take the **top item in `~/Obsidian/Inbox/`** — one per invocation, the queue drains by being worked. Four outcomes:

- **Your own record or self-fact** — file it, below.
- **External reading about the world** (article, video, book) — hand to `/ingest`.
- **One of your own ideas** — hand to `/wayfinder` (foggy) or `/grilling` (one sitting).
- **Neither** — bin it.

The capture's kind picks the drain; these are peers, not a pipeline.

## Pipeline

1. **Read** the intake. OCR any scanned PDF on the way in ([OCR.md](OCR.md)). Done when every page of every raw is text, not image.
2. **Classify** — which domain (`Personal` / `Employment` / `Ventures`) or `Profile`, and is this a **matter** or a **fact**?
3. **Content-class gate** — Class A is **third-party** secrets, PII, and financials, plus verbatim proprietary source: drop or pseudonymise. **Your own** sensitive data — your price, MPAN, policy numbers — is B-private and **kept**; the vault is end-to-end encrypted. So a vendor's name and their figures go; yours stay.
   - Raw storage: your own document is kept under the matter's `raw/`. A third-party-sensitive document gets **no raw** — derived note only.
4. **Reconcile, then judge.** Dedupe against what is already filed. Resolve each **fact** to one of **add / skip / update / retire**: *skip* a reworded duplicate, *retire* a stale fact by stamping it superseded with today's date rather than deleting it. Then **propose** the target page(s), what each gains, and the reconciliation. Hassan judges. This is the throttle — a few high-signal writes, never blind capture.
5. **Gate the consequence, not the effort.** Drafting runs free. **Employment and Profile writes are shown for approval before write**; Personal and Ventures matter notes write through.
6. **Write** what was agreed:
   - A **matter note** carries the [spine](#the-frontmatter-spine), links its raws, and keeps full B-private fidelity — intent, who, decisions, the values you will look up.
   - A **fact** updates its `Profile/` page or domain note with provenance (source + date) and any supersession stamp.
   - **Append a link on the domain hub** (`Home.md`, `Finances.md`, …). Hub links are load-bearing: grep finds a known term, the hub carries a half-remembered one.
7. **Report** which pages changed.

## Facts change — supersede, don't append

`/ingest` accretes world-facts, which stay true. Self-facts go stale: an email changes, a goal is abandoned. Blind append leaves `/ask` two contradictory answers. So a fact is **reconciled**, not appended — and a retired fact is **kept, stamped superseded with a date**, so `/ask` can still say "targeted bioinformatics until Aug 2026, then X". Raws never supersede — you keep the old policy and the new one; only *facts* do.

## The frontmatter spine

A matter note carries the vault's required keys plus a light spine, and no more. `type` stays the vault note-kind (`note`) — the document's own kind rides on `kind`, so the reserved vocabulary is untouched. `created` is the immutable intake date; `issued` is the date on the document.

```yaml
type:    note                                   # vault note-kind — see CONVENTIONS
domain:  personal | employment | ventures
created: YYYY-MM-DD                             # intake / filed date — immutable
kind:    policy | deed | letter | statement | … # what the document is
who:     <sender or recipient>
issued:  YYYY-MM-DD                             # the date on the document itself
tags:    []
```

`kind` is what-it-is, kept separate from thematic `tags`. Skip archive-serial numbers, storage-path templates, and any field nothing is queried by. A fact needs no spine — provenance and supersession are enough.

## Confidentiality

Never write Class A: **third-party** secrets, credentials, PII, or financials, and verbatim proprietary source. Your own sensitive data is B-private — the vault is encrypted; keep it. Pseudonymise a third party you must reason about (a de-identified `entity`), never their legal identity.

## Related
`/ingest` — the sibling for external reading (the world). `/ask` — query what you have filed. `/observe` — a behavioural signal to drain, not a fact to keep.
