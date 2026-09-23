---
status: accepted
---

# The spec node parents its slices, and a project is not a destination

Amends [ADR-0006](./0006-cut-is-stage-2.md)'s "slices are never sub-issues" rule and its `**Destination:**` enumeration.

## Context

ADR-0006 settled that several slices are top-level with native blocking edges, "plus a container where the tracker has one", and closed the alignment ticket so it could not become an open parent. It ruled slices away from sub-issues for two reasons: nesting puts the build labels a level down, and a closed parent would hang live work off something dead.

Both reasons were about a parent that wears a workflow label and is closed under open children. A spec node does neither. It holds the map rather than the contract — the scenario-to-slice assignment and the shared interfaces with the consumers that claim them — so it makes no buildability claim a child's label could differ from, and its state is the rollup its own children produce.

Running `/cut` against GitHub in September 2026 also showed the second reason was a statement about *when* the parent closes rather than about nesting: `gh issue edit --parent` and `--add-sub-issue` are native, and GitHub will not close a parent when its last child closes.

## Decision

**Where the tracker has native sub-issues, a container is a spec node that parents the slices.** It carries no workflow label, is checked as a map only, and closes when its last slice closes — a rule `/build`'s record step owns, because GitHub does not close it.

- **The container's state is the rollup.** `1/3`, `2/3`, `3/3` — honest while the slices are live, which `ready-to-cut` and `ready-to-build` could never be on an open parent.
- **A spec is not a destination.** `**Destination:**` names **tickets**, a **proposal**, an **ADR**, or nothing; a container rides inside the tickets exit. ADR-0006's "a project" put a tracker object into a content property — the conflation ADR-0006 rejected for the label set, one step down.
- **The alignment ticket still closes at the cut**, keeps its number and its body, and is never the container.

## Considered options

- **Closing the spec at the cut** — rejected. Its children are still open, which is the fault ADR-0006 named: a closed parent with live children is the one shape that reads as finished when it is not.
- **A plain linked issue — `Part of #90`, no sub-issue edge** — rejected. It is the fallback `/wayfinder` already documents, and it gives up the child list and the rollup for nothing.
- **No container on GitHub, the closing comment as the map** — rejected. The map is the one artefact the cut produces that no other node carries, and a comment cannot be checked as a map.
