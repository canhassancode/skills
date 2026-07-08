---
status: accepted
---

# Triage-free planning lane (adopt Matt Pocock's spec → tickets → implement flow)

## Context

This fork diverged from `mattpocock/skills` with a deliberately richer graph: a `triage` state machine that produces an `agent brief`, verified at `pickup`, plus `handoff`/`receive` for session continuity — all documented in `CONTEXT.md`. Planning output flowed through it: `grill-with-docs` → `to-prd` (a `prd`-labelled epic, with a `## Status` block maintained by `triage`) → `to-issues` (HITL/AFK slices → `needs-triage`/`ready-for-human`).

Matt's v1.1.0 introduced a different way of working. Its planning skills — `to-spec`, `to-tickets`, `wayfinder` — publish straight to `ready-for-agent` **by construction** and never route through triage ("agent-grabbable by construction"). His flow is a clean line: grill → spec → tickets → implement → code-review → commit. He did not remove `triage`; his new flow simply bypasses it.

We chose to try that way of working rather than adapt his skills back into our triage-integrated shape.

## Decision

Adopt Matt's planning lane and make it **triage-free**, while keeping our triage graph for **inbound** work.

- **Deprecate** `to-prd` → `to-spec` and `to-issues` → `to-tickets` (moved to `deprecated/` with redirect stubs). `to-spec`/`to-tickets` are vendored from `mattpocock/skills` v1.1.0, effectively unchanged (only their `/setup-matt-pocock-skills` pointer was repointed at `/bootstrap`).
- **Planning is triage-free.** `grill-with-docs` now routes at close to `to-spec` (published `ready-for-agent`), and `triage`'s promote action becomes **promote-to-spec**. The `prd` type label is retired.
- **Triage survives, scoped to inbound work** — user bugs, collaborator drafts, stale tickets. `triage`/`pickup`/`handoff`/`receive` and the four-pass discipline are unchanged for that lane.
- **`code-review`** (Matt's, two-axis with a Fowler smell baseline) is imported to run **alongside** `review`, not replace it — `implement` calls `code-review`.
- **`bootstrap`** supersedes `setup-tracker`: it writes both config surfaces — our `tracker:` preference (triage lane) and Matt's `docs/agents/*.md` (planning lane).
- Also imported: `wayfinder`, `implement`, `research`, `prototype`.

## Considered options

- **Adopt the ideas, keep our plumbing** — rewire Matt's imports to our triage graph (re-add Status block, `prd` label, HITL/AFK). Rejected: that recreates `to-prd`/`to-issues` under new names and doesn't actually try his way of working.
- **Wholesale replace our graph with his line** — retire `triage`/`pickup`/`handoff`. Rejected: throws away deliberate machinery that is sharp for inbound work, which his line doesn't cover.
- **Two parallel plugins** (`npx skills add mattpocock/skills` beside ours) — rejected: 10 skill-name collisions (`tdd`, `grilling`, `triage`, …) make model-invocation ambiguous.
- **Vendor the net-new skills into this repo, deprecate the two planning skills, planning goes triage-free** — chosen: coherent version of "try his way", no name collisions (his net-new names don't clash with ours), triage graph preserved for the lane it's best at.

## Consequences

- **Two provenances for `ready-for-agent`:** the planning lane (a grilling stands behind the brief) and the inbound lane (`triage` produced it). Same label, different origin — recorded in `CONTEXT.md`.
- The imported planning skills read `docs/agents/issue-tracker.md`; the triage lane reads the `tracker:` preference. `bootstrap` seeds both. GitHub is the only tracker where both lanes are fully wired; Linear works for triage but the planning lane falls back to a described workflow.
- **Refactoring now happens twice** on the planning lane: our `tdd` keeps refactor in-loop, and `code-review` refactors via Fowler smells. Left as-is for now; trimming `tdd`'s refactor step is tracked in issue #14.
- Harness config (`CLAUDE.md` for Claude Code, `AGENTS.md` for pi, both in `dotfiles`) must be taught the two lanes and when to use each — a **separate follow-up PR in the dotfiles repo**, pointing at the merged skills.
- ADR-0001's "a PRD maps to a native Linear Project" now reads as **spec** → Project; the dual-track adapter decision itself stands.
- Reversible: the whole change lands on a branch behind a PR.
