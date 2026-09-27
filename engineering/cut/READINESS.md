# Readiness check

The eleven-row test a body passes before it takes a takeable stamp. Failing any row refuses the stamp.

Three readers: `/cut` applies it to every slice it stamps; `/align`'s close applies it to the whole contract whenever it stamps a takeable state — `ready-to-cut` or `ready-to-build`; `/diagnose`'s Phase 6 stamp applies it to the ticket the diagnosis leaves behind, before that ticket takes `ready-to-build`.

| # | row | the check |
| --- | --- | --- |
| 1 | What this builds | one paragraph; on a slice, the alignment's `# Problem statement` transcribed verbatim |
| 2 | Scenarios | at least one, its outcome named, the outcome observable |
| 3 | Acceptance criteria | each falsifiable, traced to the scenario it makes pass, carrying the command that decides it and the evidence that counts as passing |
| 4 | Interfaces | every row owned or consumed, no orphan |
| 5 | Decisions | each settled one with its rejected alternative and why |
| 6 | Out of scope | each with the reason it was rejected |
| 7 | Boundaries | always / ask first / never |
| 8 | Unresolved | empty — any entry refuses the stamp |
| 9 | Sources | resolving (link + version + date), never referring |
| 10 | Blockers | native edges, each naming a real ticket |
| 11 | Axes | every one of the nine marked, with the coverage line totalling the list |

Rows 1–10 are checked against the slice's body. Row 11 reads the axes on the alignment body's coverage line — **Axes:** n decision · n N/A — which totals the nine: happy path · limits · failure · misuse · concurrency and idempotency · permissions · observability · rollback · cost. A slice reads the marks rather than re-filling them.

**Container route.** Every slice passes on its own. The spec node is checked as a map only: every scenario assigned to exactly one slice, every shared interface naming the slice that builds it and the consumers that claim it, no label. A shared row whose `built by` names no slice refuses the stamp. It carries no criteria and no boundaries of its own.

**Refusal.** One unwritable slice, or one failed row, refuses the cut as one act — no node is written, the passing slices are not published, and the ticket keeps `needs-alignment` with the failing rows named in a comment.
