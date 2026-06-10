---
name: lint
description: Sweep the Obsidian vault for conformance to CONVENTIONS.md — Class A leaks, missing/invalid frontmatter, naming, archive markers, index reconciliation, overview bloat. Auto-fixes safe rules; proposes destructive ones. Use to tidy the vault or after changing the conventions.
---

# Lint

The vault's integrity sweep. `CONVENTIONS.md` is the **rule authority** — lint enforces it *retroactively* (the write-skills enforce it forward). Because the rules are prose and lint is LLM-driven, they're directly executable: **change a rule in `CONVENTIONS.md`, run `/lint`, the vault reconforms.** Read `~/Obsidian/CONVENTIONS.md` and `~/Obsidian/CONTEXT.md` first. If `~/Obsidian/` is absent, stop.

## Sweep order

Iterate the **Rules (lint checklist)** in `CONVENTIONS.md` (R1–R8). Run roughly in this order:

1. **Class A + clutter (R0/R8)** — scan for secrets, credentials, customer PII and financial data, verbatim proprietary source, and stray scaffolds (`Untitled.*`). Highest priority; a leak is real harm at any scale. Note: file paths + commit SHAs are **not** Class A (B-private — leave them); also check customer *identity* is pseudonymised. `[confirm]` before removing/editing.
2. **Frontmatter & type (R1, R2)** — every note outside `Inbox/` has required frontmatter; `type` ∈ the vocabulary. `[fix]`.
3. **Naming (R3) & folders (R4)** — match each type's naming rule; folders Title Case, system files lowercase. `[confirm]` — see rename safety.
4. **Archive markers (R5)** — files under `Archive/` carry `[[Archive]]` + `archived:`. `[fix]`.
5. **Index reconcile (R6)** — Library `index.md` ↔ files on disk agree. `[fix]`.
6. **Overview trim (R7)** — `Profile/overview.md` within its ~½-page budget. `[confirm]`.

## Fix discipline

- **`[fix]`** rules apply automatically. **`[confirm]`** rules are proposed in a batch and wait for approval.
- **Rename safety** — a rename breaks every `[[wikilink]]` to the old name. Never rename silently: **propose → confirm → rename the file and rewrite all backlinks atomically.** This is the one place "just like eslint --fix" does not hold.
- Default to flagging over rewriting when a rule is a judgement call.

## After the sweep

- Report what was auto-fixed and what needs a decision.
- Append `log.md` for any Library changes: `## [YYYY-MM-DD] lint | <summary>`.

## Related
`/inbox`, `/ingest` — enforce `CONVENTIONS.md` forward · `CONVENTIONS.md` — the rules lint reads
