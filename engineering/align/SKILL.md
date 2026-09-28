---
name: align
description: Accepting a users new feature, requirements, general idea, ticket, PR comments and challenging against the existing domain, sharpening terminology, and making updates to artefacts and documentation (CONTEXT.md, ADRs, Sequence Diagrams). Use when users want to stress-test and align on their project's language and documented decisions.
argument-hint: <new feature | ticket-ref | requirements | pr comments | general idea>
---

## The pass

A _pass_ is one session, and it runs in four parts — **playback, rounds, design, close** — then stops. You are pairing through discovery: every reply follows [EXAMPLES.md](EXAMPLES.md), and every choice of wording is there to leave the user well-equipped.

1. **Gather.** Fan out to sub-agents for the facts the pass turns on — at most two at a time, each returning its conclusion with `file:line`, not the files it read. From pass 2 onwards, read the ticket body only; fetch a pass comment when a question needs it. Questions wait for the research that answers them, and the round never waits for the slowest source.
2. **Playback.** Before any question, say back what exists today, what is being asked, and one diagram of today's flow, in plain words and with the room it needs to be understood. Close it with the pass's scope in one line: the one area this pass settles, sized to fit a ~100K-token session, with everything else sent to Unresolved carrying its route. The playback is done when the user has confirmed or corrected it.
3. **Rounds.** Run `/grilling`'s round shape — read [grilling/SKILL.md](../grilling/SKILL.md): one scenario per round and the questions it raises. Run `/domain-modeling` alongside it — challenge against the glossary, sharpen fuzzy language, cross-reference against code, update `CONTEXT.md` inline, offer ADRs. Rounds end when the scope's behaviour is settled.
4. **Design.** Run `/codebase-design` with the user, one interface at a time: its signature as code, a caller using it, its invariants and error modes, and a sequence diagram where the flow changes. Ask about each before showing the next. The design is done when every interface the scope touches has been shown and agreed.
5. **Close.** Route the output by the table below, then stop. The next pass is `/align <ref>` in a fresh session.

**The round.** Two to four questions, each carrying one recommendation. In playback and rounds, the names of functions, columns and ids sit on the fact line; in design they are the subject. Every waivable case carries an impact line under its question — what goes wrong, for whom, and how many — counted from data where it is reachable, otherwise `not counted`, with the reason and the question left open.

**The short pass.** A build that finds a gap routes it back to `/align` as a contract change, and the pass it runs is short by default: one round, where every answer takes one of three exits — fixed in this ticket, out of scope, a new ticket — and the close below runs in full either way. A full pass runs instead when the answer would change another slice's promise. An item left open lands in Unresolved, so the ticket returns to `needs-alignment` and the build stops.

**Pass 1 on a placeholder.** A ticket queued by `/triage` carries no `Passes:` header — the shape is in [EXAMPLES.md](EXAMPLES.md). The first pass folds its Triage notes into Background, then writes the header and the rest of the rows.

## At session close - route the output
An alignment is a _thinking_ artefact, not by default a spec or a build. The close has five exits — `needs-alignment`, `needs-info`, `ready-to-propose`, `ready-to-cut`, `ready-to-build` — and the row it takes is read from the body, never guessed from the conversation. The routes are:

| the pass ends on | Verdict | Destination | Ticket state | Next |
| --- | --- | --- | --- | --- |
| the body already carries the contract | aligned | `tickets` | `ready-to-build` | `/build` |
| the contract is settled but the cut is owed | aligned | `tickets` | `ready-to-cut` | `/cut` → one ticket, or slice tickets at `ready-to-build` → `/build` |
| a yes is owed outside the room | aligned | `proposal` | `ready-to-propose` | `/propose` → `awaiting-decision` → yes: `ready-to-cut` · change: `needs-alignment` with the objections · no: `wontfix` |
| the deliverable is the decision itself | aligned | ADR, or nothing | none — the ticket closes | write the ADR, update `CONTEXT.md`, stop |
| decisions still open | fog | unchanged | `needs-alignment` | `/align <ref>` again — every unresolved item carries the route that would settle it |
| unresolved items with no route, axes unmarked, or no decisions recorded | thin | unchanged | `needs-alignment` | record what is missing, then `/align <ref>` |
| what is open is a fact, not a decision | fog | unchanged | `needs-info` | clear the fact (`/research`, a sub-agent, the vendor's docs), then `/align <ref>` |
| the work is not worth doing | dropped | nothing | none — the ticket closes | record the reason in one paragraph, close `wontfix` where a ticket exists, stop |

**The close writes three things and refuses more**: the ticket's body and its pass comment, the ADR where one is owed, and `CONTEXT.md` inline. The pass preps work, it does not execute it — the files a ticket delivers land after the cut and the readiness check. A route answer is never write permission: `/align` creates no node on its own, and no node is written without its body shown and confirmed first.

The body carries the pass count, the verdict, the destination, what the pass was verified against, the unresolved items with their routes, and the next act. A pass comment carries only what moved in that pass.

A contract that takes either takeable exit — `ready-to-cut` or `ready-to-build` — passes the eleven rows in [READINESS.md](../cut/READINESS.md) before the stamp; a failed row keeps the work at `needs-alignment` with the failing rows named, so `/cut` never reads a body still carrying fog.

Where the body lists slices, the close dry-runs the cut's assignment by hand before it stamps a takeable state — every scenario landing in exactly one slice, every slice naming the scenario it makes pass — and shows the slice table, one row per slice, in the map's own signature, so the operator sees the assignment before the stamp rather than in a refusal afterwards:

| slice | scenarios | blocked by |
| --- | --- | --- |

`/cut` still owns the split; the run decides nothing. A scenario in no slice or two, or a slice naming no scenario, refuses the stamp the way a failed readiness row does: the work stays at `needs-alignment` with the failing rows named.

## Additional Files
**Examples**: See [EXAMPLES.md](EXAMPLES.md)
