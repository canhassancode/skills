---
name: cut
description: Cut a settled alignment into a spec node and slices that carry their own contract.
argument-hint: <ticket-ref | current conversation>
disable-model-invocation: true
---

# Cut

`/cut` reads a settled alignment's **body** — the pass comments are only the delta — and turns it into slices a builder can pick up cold. It transcribes: it decides nothing, invents no row, and writes no node until the whole set passes.

One slice, and the ticket graduates in place. Several, and a **Spec** node parents them: it carries the map — the scenario-to-slice assignment, the shared interfaces and their consumers — and wears no label. [SPEC.md](SPEC.md) is the map's shape; [TICKET.md](TICKET.md) is a slice's.

The roles in this skill are canonical; the label strings are the repo's — read [`docs/agents/triage-labels.md`](../../docs/agents/triage-labels.md) and apply its strings. The operations live in [`docs/agents/issue-tracker.md`](../../docs/agents/issue-tracker.md) (*publishing a cut*). Nothing global is read at run time.

# Procedures

1. **Read.** Fetch the alignment ticket's body and its pass comments. A body still carrying fog is not a cut's input: it wears `needs-alignment`, and the next act is another `/align` pass.
2. **Assign.** Every scenario lands in exactly one slice; every interface row is owned or consumed; every decision binds the slices it touches. A slice that cannot name the scenario it makes pass is a **Layer** — a branch, not a tracker node. Each slice takes a title in the shape [TICKET.md](TICKET.md) gives, a body transcribed from the contract, and its blocking edges.
3. **Check.** Apply [READINESS.md](READINESS.md) to every slice. One unwritable slice, or one failed row, **refuses the cut as one act**: write nothing, publish none of the passing slices, and return the work to `needs-alignment` with the failing rows named. Never fill the gap with prose at the cut.
4. **Show.** Present the set: every slice's body, every blocking edge, the map where there is one. Ask the operator to confirm the set. Nothing is created before that confirmation — the cut is atomic.
5. **Create.** Publish in one pass. One slice: the alignment ticket graduates in place, keeping its number and its body, and takes `ready-to-build`. Several: create the spec node first, unlabelled, then each slice as its child at `ready-to-build`, its native blocking edges set as it lands.
6. **Close.** Close the alignment ticket with one comment naming the slices — carrying the map where no spec node was created. The cut is done when every slice exists and the ticket's body is the frozen record.

# Labels

| node | state |
| --- | --- |
| a slice | `ready-to-build` — stamped only after its own readiness check passes |
| the spec node | none — its body is a map, so no takeable claim is true of it |
| the alignment ticket, one-slice route | `ready-to-build`, replacing `ready-to-cut` |
| refused work | `needs-alignment`, the failing rows named |

# Relationships

- A spec node exists only where the tracker has a native container. Where it has none, the slices are top-level with native blocking edges and the closing comment carries the map.
- A spec parents its slices; nothing else nests. Slices are peers — ordering is a blocking edge, never a parent.

# Additional files

**Examples**: See [EXAMPLES.md](EXAMPLES.md).
