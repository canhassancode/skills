# Readiness check

The twelve-row test a body passes before it takes a takeable stamp. Failing any row refuses the stamp.

Three readers: `/cut` applies it to every slice it stamps; `/align`'s close applies it to the whole contract whenever it stamps a takeable state — `ready-to-cut` or `ready-to-build`; `/diagnose`'s Phase 6 stamp applies it to the ticket the diagnosis leaves behind, before that ticket takes `ready-to-build`. The check runs quietly: the operator hears only the rows that fail.

| # | row | the check |
| --- | --- | --- |
| 1 | Header | `Verified against` names a sha; a slice also carries its **Size** by [TICKET.md](TICKET.md)'s rule |
| 2 | What this builds | two or three plain sentences: what it does once it ships, and what is true today |
| 3 | Scenarios | numbered from 1; each names who, the starting state, the trigger and what is observed |
| 4 | Acceptance criteria | each falsifiable, naming its scenario and witness, decided by a named command; every scenario has one |
| 5 | Terms | every project term is in `CONTEXT.md` or glossed where it first appears |
| 6 | Decisions | each binds this body and carries its reason; none contradicts the body of a ticket it is blocked by |
| 7 | Premises | every fact about code, data or runtime cites a probe pinned to the sha — a `path:line @ sha` with its symbol, or a command with its output; "pass 2" is not a probe |
| 8 | Live prerequisites | every **Live** criterion's fixture, credentials and outside-write permission are provisioned, or routed as a task |
| 9 | Boundaries | always / ask first / never |
| 10 | Blocked by | each a real ticket, matching the native edges |
| 11 | Unresolved | `None.` — any entry refuses the stamp |
| 12 | Axes | every one of the nine marked, with the coverage line totalling the list |

Row 12 reads the axes on the alignment body's coverage line — **Axes:** n decision · n N/A — which totals the nine: happy path · limits · failure · misuse · concurrency and idempotency · permissions · observability · rollback · cost. A slice reads the marks rather than re-filling them.

**Container route.** Every slice passes on its own. The spec node is checked as a map only: every scenario assigned to exactly one slice, every shared piece naming the slice that builds it and the slices that use it, no label. A shared piece whose `built by` names no slice refuses the stamp.

**Refusal.** One unwritable slice, or one failed row, refuses the cut as one act — no node is written, the passing slices are not published, and the ticket keeps `needs-alignment` with the failing rows named in a comment.
