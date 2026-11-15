---
status: accepted
---

# One writer per ticket, verified as it is built, and no locked tests

Supersedes ADR-0009 and ADR-0011, and the per-child align of ADR-0006.

## Context

brigade#136 took about ten hours of the operator's time across three align sessions, then a four-hour build. Its four units were written in 22 minutes. The remaining 3h45m was five crucible passes, eight fix commits and five verifier runs, because nothing ran the app until every unit was in (transcripts, 2026-11-10 to 2026-11-14). The 22 locked tests were green while the app never got its keys, since they ran on fakes. The Delegator never held a diff, yet it still peaked at 201k tokens. Across 19 build sessions the median peak was 139k. Crucible's spec check found about one of 20 findings, and mutation found none on its own.

## Decision

- **`/align` grills and specs, nothing more.** It runs in rounds with recommendations. Glossary terms are written as they settle. The spec is written once at the end from the conversation, and the operator gives one yes. There are no interface stubs, no `/tester` and no per-term approvals. A longer ask still runs across sessions, carried by one session comment.
- **`/cut` publishes `ready-to-build` tracer bullets**, each sized to one fresh session. `needs-alignment` is kept only for a child with an open question.
- **`/build` is one writer per ticket.** The session writes the code itself, test-first at the spec's seams. Subagents only read: the reuse search, the Verify run and crucible. Verify runs on the real app before the pull request, and the builder self-reviews against the coding rules before crucible sees the diff.
- **Tests are written in the loop, not locked ahead of it.** `/tester`, the validator, the lock check and the edit hook retire.
- **`/crucible` is one pass plus one re-pass at most.** It checks the spec, walks for correctness, checks rules, greps consumers and checks claims. Mutation runs only when a fix adds no test.

## Consequences

- A ticket can take more than one `/build` session. A Resume line in the pull request carries it over. A third session means the ticket was cut too big.
- Nothing stops a builder from editing a test. Crucible's spec check and the Verify run are now what catch a weakened test.
- Measure the change: wall-clock per ticket, operator turns per align, and escaped defects. If they don't drop, revisit this ADR.
