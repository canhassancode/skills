---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

## Procedure

1. Prompt the user: "Fan-out via subagents (scout + ask + researcher) or linear?"
   - Fan-out: launch three parallel async subagents, then go to step 2
   - Linear or no answer: go to step 3
   - Subagents unavailable: go to step 3

2. Wait for subagent results. Read ADRs and CONTEXT.md only — do not explore
   code or grep files (the subagents cover that). Check subagent status only
   if a needs_attention signal fires.

3. Synthesise findings (if fan-out) and interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Second-brain awareness (if `~/Obsidian/` exists)

If `~/Obsidian/CLAUDE.md` is absent, skip this section silently — do not block. With no repo to ground against, the vault is `grill-me`'s *only* prior-art source, so it matters more here than in `/grill-with-docs`.

- **Open with a sweep** — an index-first `/ask` on the session topic to surface prior grillings, ingested material, and Profile focus that bear on it. One topic sweep + targeted re-queries; never a blanket dump.
- **Authority order** — a vault page is a snapshot; if it contradicts current reality, surface it as a flag, don't trust it blindly.

## Capture at close (if `~/Obsidian/` exists)

At the **end** of the session, offer once: *"Capture this grilling into the Library?"* On yes, hand a session summary to `/ingest` (session mode → a `grill`-sourced Library page). Capture decisions and rationale; **never** write Class A (secrets, customer PII, verbatim proprietary source) — paths/SHAs are B-private, fine to keep. Never auto-capture; skip silently if the vault is absent.
