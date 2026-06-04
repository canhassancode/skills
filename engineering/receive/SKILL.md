---
name: receive
description: Resume an agent handoff from the Obsidian vault — list the docs in Handoffs/ by title only (without absorbing them), let the user pick when there's more than one, then absorb the chosen doc's context, offer its durable residue to the Library, and archive it. Use when starting a fresh session to continue handed-off work. The session analogue of /pickup (which resumes a tracker ticket).
---

# Receive

Resumes a **handoff** written by `/handoff`. The session-continuity counterpart to `/pickup` (which verifies a _ticket_) — kept distinct so neither term is overloaded. Read `~/Obsidian/CONTEXT.md` and `~/Obsidian/CONVENTIONS.md` first.

> Named `receive`, not `resume`/`continue` — those are reserved session commands in Claude Code and pi.dev and would be shadowed by the built-in.

## Procedure

1. **List** the handoffs in `~/Obsidian/Handoffs/`. Cases:
   - **None** — say so and stop.
   - **One** — name it and proceed to absorb (no need to ask).
   - **More than one** — present a numbered list and let the user pick which to receive. **Read only the cheap header of each file — its H1 title (`# Handoff — …`) and `created:` date — never the body.** This is a title-only menu; do not absorb any handoff's context until one is selected. If the user named a handoff in their invocation, skip the menu and use that one.
2. **Absorb** — once one is selected, read *that* doc and the pages it wikilinks (`/ask` the linked Library/Profile pages as needed) until you can continue the work from live context, not just the doc.
3. **Confirm** with the user what you're picking up and the intended next step. Run any skills the handoff suggests.
4. **Harvest residue** — if the handoff (or the work since) produced durable knowledge worth keeping, offer once to `/ingest` it into the Library (a `grill`/session-mode source). Decisions and rationale only; never Class A.
5. **Archive** — once you're operating from live context (pickup complete), move the file to `~/Obsidian/Archive/Handoffs/`, append `[[Archive]]` to its footer, and stamp `archived: <YYYY-MM-DD>` in frontmatter (per `CONVENTIONS.md` → Archiving). Dead handoffs don't accumulate.

## When to archive

At **pickup-complete**, not pickup-start — so a mid-resume re-read still finds the file in `Handoffs/`. Archiving and residue-harvest are one lifecycle event.

## Rules

- Never write Class A (secrets, PII, code maps). Handoffs are Class B working context.
- If `~/Obsidian/` is absent, this skill has nothing to act on — say so and stop.

## Related

`/handoff` — writes the doc this resumes · `/pickup` — the ticket analogue · `/ingest` — harvest durable residue
