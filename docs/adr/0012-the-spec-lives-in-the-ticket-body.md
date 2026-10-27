---
status: accepted
---

# The spec lives in the ticket body

Amends [ADR-0011](./0011-locked-tests-replace-the-contract-pipeline.md): where a spec lives.

## Context

The rewrite put every spec in the repo at `docs/specs/<capability>.md`, a parent on its own `spec/<capability>` branch and pull request, with only a goal line and a link in the ticket. The first real `/align` on a child, on 2026-10-27, broke that in practice: its parent's spec was already in the Linear body, the repo had never had a `docs/specs/`, and the operator moved the child's spec back into its ticket. Colleagues read the tracker, not branches, and a parent's spec pull request was one nobody built from.

## Decision

A spec is its ticket's body: a parent's on the parent ticket, a child's on its own. `/align` replaces the body whole at close; `/cut` publishes each child's goal and draft behaviour lines as the first sections of that child's body and turns the parent's Children list into its checklist. A parent has no branch. A child's stubs and locked tests stay on `feat/<capability>`, in the draft pull request `/align` opens and `/build` marks ready.

## Consequences

- `/build`, its builders, `/tester`, `/crucible`, `/review` and `/shepherd` read the spec from the ticket, so each needs the tracker's read operation; none gains a new permission, because each already reads or labels the ticket.
- A spec change made after the lock no longer shows as a diff in the pull request. Its Decisions line and the tracker's own edit history carry it.
- The tracker templates gain a write-the-spec operation and lose the spec pull request.
