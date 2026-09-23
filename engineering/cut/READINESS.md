# Readiness check

The ten-row test a body passes before it is stamped `ready-to-build`. Failing any row refuses the stamp.

Two readers: `/cut` applies it to every slice it stamps; `/align`'s close applies it when a single-deliverable contract graduates.

| # | row | the check |
| --- | --- | --- |
| 1 | Scenarios | at least one, its outcome named, the outcome observable |
| 2 | Acceptance criteria | each falsifiable, traced to the scenario it makes pass, carrying the command that decides it and the evidence that counts as passing |
| 3 | Interfaces | every row owned or consumed, no orphan |
| 4 | Decisions | each settled one with its rejected alternative and why |
| 5 | Out of scope | each with the reason it was rejected |
| 6 | Boundaries | always / ask first / never |
| 7 | Unresolved | empty — any entry refuses the stamp |
| 8 | Sources | resolving (link + version + date), never referring |
| 9 | Blockers | native edges, each naming a real ticket |
| 10 | Axes | every one of the nine marked, with the coverage line totalling the list |

Rows 1–9 are checked against the slice's body. Row 10 reads the axes on the alignment body's coverage line — **Axes:** n decision · n N/A — which totals the nine: happy path · limits · failure · misuse · concurrency and idempotency · permissions · observability · rollback · cost. A slice reads the marks rather than re-filling them.

**Container route.** Every slice passes on its own. The spec node is checked as a map only: every scenario assigned to exactly one slice, every shared interface claimed by a consumer, no label. It carries no criteria and no boundaries of its own.

**Refusal.** One unwritable slice, or one failed row, refuses the cut as one act — no node is written, the passing slices are not published, and the ticket keeps `needs-alignment` with the failing rows named in a comment.
