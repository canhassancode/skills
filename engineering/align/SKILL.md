---
name: align
description: Accepting a users new feature, requirements, general idea, ticket, PR comments and challenging against the existing domain, sharpening terminology, and making updates to artefacts and documentation (CONTEXT.md, ADRs). Use when users want to stress-test and align on their project's language and documented decisions.
argument-hint: <new feature | ticket-ref | requirements | pr comments | general idea>
---

## The pass

A _pass_ is one session: a conversation that settles one area so a build can run without stopping to ask. Every reply follows [EXAMPLES.md](EXAMPLES.md). Read [grilling/SKILL.md](../grilling/SKILL.md) and [domain-modeling/SKILL.md](../domain-modeling/SKILL.md) before the first question — their rules govern every round.

1. **Gather.** Fan out to sub-agents for the facts the pass turns on — at most two at a time, each returning its conclusion with `file:line`, not the files it read. From pass 2 onwards, read the ticket body only; fetch a pass comment when a question needs it.
2. **Playback.** Before the first question, say back in one short paragraph what exists today and what is being asked, then the pass's scope in one line — the one area it settles, sized to a ~100K-token session, everything else sent to Unresolved with its route. The playback is done when the user confirms or corrects it.
3. **Rounds.** Run `/grilling`: one scenario, one question, one recommendation, then wait. Answer the user's own questions before asking the next. Challenge as grilling says — an answer that clashes with the code, `CONTEXT.md`, an ADR or something said earlier is put back with the evidence before it is recorded.
4. **Walk.** Before any interface is agreed, a sub-agent walks the code the change will run through, with the inputs production can send: rows written before the change, two calls at once, a missing or malformed value, every tracker and platform the code serves. A case with one safe outcome becomes a decision row; a case that is a real choice becomes the next round's question, told as a concrete example. Every fact the contract rests on becomes a **premise** with its probe — a `path:line @ sha` with its symbol, or a command and its output. A premise reading cannot settle — whether a socket mounts, whether old records hold the field — is run, not argued: it takes the **prototype** route as a throwaway spike, and the spike's output is its probe.
5. **Design.** Only for an interface the change adds or reshapes: its signature as code and one caller, one interface at a time, asked about before the next. Nothing else is shown.
6. **Close.** Show the shared understanding in a few lines and ask the user to confirm it, then route the output by the table below, and stop. The next pass is `/align <ref>` in a fresh session.

**Show, don't diagram.** A scenario carries the explanation: who, what they do, what happens. Draw a diagram only when the user asks. When the user would need to see the thing to judge it — a layout, a CLI's output, a flow they would click through — offer a **prototype** instead.

**The route.** Every Unresolved entry names one **Route** and what it leaves behind: **research** — a fact read from primary sources by a `/research` sub-agent, landing as a cited note; **prototype** — a shape to react to or a premise to run, via `/prototype`, landing as a throwaway branch linked from the pass comment; **task** — work that must happen before the discussion can move (provisioning a fixture, credentials, a permission), landing as a fact row; **pass** — more rounds in a fresh session; **decide** — a yes owed outside the room, `/propose`'s. Each entry carries its owner and where the artefact lands.

**The short pass.** A build that finds a gap routes it back as a contract change, and the pass it runs is short by default: one round, where every answer takes one of three exits — fixed in this ticket, out of scope, a new ticket — and the close runs in full. A full pass runs instead when the answer would change another slice's promise. An item left open lands in Unresolved, so the ticket returns to `needs-alignment` and the build stops.

**Pass 1 on a placeholder.** A ticket queued by `/triage` carries no `Passes:` header — the shape is in [EXAMPLES.md](EXAMPLES.md). The first pass folds its Triage notes into Background, then writes the header and the rest of the rows.

## Writing

Nothing is written without a yes for that item. A term goes into `CONTEXT.md` only after it is proposed as its own one-line question; an ADR is written only after domain-modeling's three criteria hold and it is put as its own question — never bundled into a "write all of these". The ticket body and the pass comment are shown before they post. A route answer is never write permission.

## At session close - route the output

An alignment is a _thinking_ artefact, not by default a spec or a build. The row the close takes is read from the body, never guessed from the conversation:

| the pass ends on | Verdict | Destination | Ticket state | Next |
| --- | --- | --- | --- | --- |
| the body already carries the contract | aligned | `tickets` | `ready-to-build` | `/build` |
| the contract is settled but the cut is owed | aligned | `tickets` | `ready-to-cut` | `/cut` → one ticket, or slice tickets at `ready-to-build` → `/build` |
| a yes is owed outside the room | aligned | `proposal` | `ready-to-propose` | `/propose` → `awaiting-decision` → yes: `ready-to-cut` · change: `needs-alignment` with the objections · no: `wontfix` |
| the deliverable is the decision itself | aligned | ADR, or nothing | none — the ticket closes | the ADR the user said yes to, `CONTEXT.md`, stop |
| decisions still open | fog | unchanged | `needs-alignment` | clear the named routes, then `/align <ref>` |
| unresolved items with no route, axes unmarked, or no decisions recorded | thin | unchanged | `needs-alignment` | record what is missing, then `/align <ref>` |
| what is open is a fact, not a decision | fog | unchanged | `needs-info` | clear it with a **research** route, then `/align <ref>` |
| the work is not worth doing | dropped | nothing | none — the ticket closes | the reason in one paragraph, close `wontfix` where a ticket exists, stop |

The body carries the pass count, the verdict, the destination, the sha it was verified against, the premises with their probes, the unresolved items with their routes, and the next act. A pass comment carries only what moved in that pass.

A contract that takes `ready-to-cut` or `ready-to-build` passes [READINESS.md](../cut/READINESS.md) first. The check runs quietly: the user hears only a failing row, and a failed row keeps the work at `needs-alignment` with that row named. Assigning scenarios to slices is `/cut`'s.

## Additional Files
**Examples**: See [EXAMPLES.md](EXAMPLES.md)
