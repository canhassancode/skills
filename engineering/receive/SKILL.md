---
name: receive
description: Resume an agent handoff from the Obsidian vault — list the docs in Handoffs/ by title only (without absorbing them), let the user pick when there's more than one, then absorb the chosen doc's context and delete it. Use when starting a fresh session to continue handed-off work.
disable-model-invocation: true
---

# Receive

Resumes a **handoff** written by `/handoff` — context transfer within a task, across a window reset or a worktree crossing. Read `~/Obsidian/CONTEXT.md` and `~/Obsidian/CONVENTIONS.md` first.

> Named `receive`, not `resume`/`continue` — those are reserved session commands in Claude Code and pi.dev and would be shadowed by the built-in.

## Procedure

1. **List** the handoffs in `~/Obsidian/Handoffs/`. Cases:
   - **None** — say so and stop.
   - **One** — name it and proceed to absorb (no need to ask).
   - **More than one** — present a numbered list and let the user pick which to receive. **Read only the filename and the H1 title (`# Handoff — …`) of each file — never the body.** This is a title-only menu; do not absorb any handoff's context until one is selected. If the user named a handoff in their invocation, skip the menu and use that one.
2. **Absorb** — once one is selected, read *that* doc and the pages it wikilinks until you can continue the work from live context, not just the doc.
3. **Confirm** with the user what you're picking up and the intended next step. Run any skills the handoff suggests.
4. **Delete** — once you're operating from live context, delete the file from `~/Obsidian/Handoffs/`. No archive. A received handoff does not exist, so a non-empty `Handoffs/` always means real open work.

## When to delete

At **resume-complete**, not resume-start — so a mid-resume re-read still finds the file in `Handoffs/`.

## Rules

- Never write Class A (secrets, credentials, customer PII, verbatim proprietary source). Handoffs are Class B working context — paths/SHAs are fine (B-private).
- If `~/Obsidian/` is absent, this skill has nothing to act on — say so and stop.

## Related

`/handoff` — writes the doc this resumes
