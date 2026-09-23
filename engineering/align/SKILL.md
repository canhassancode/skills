---
name: align
description: Accepting a users new feature, requirements, general idea, ticket, PR comments and challenging against the existing domain, sharpening terminology, and making updates to artefacts and documentation (CONTEXT.md, ADRs, Sequence Diagrams). Use when users want to stress-test and align on their project's language and documented decisions.
argument-hint: <new feature | ticket-ref | requirements | pr comments | general idea>
---

## Procedures of the alignment loop

1. Run `/grilling` for the interview loop.
2. Fan-out to subagents upfront, gather details from relevant sources. **Do not** reply to the user with questions or anything further until all initial research has been gathered.
3. Combine with running `/domain-modeling` for domain work - challenge against the glossary, sharpen fuzzy language, stress-test with scenarios, cross-reference against code, update `CONTEXT.md` inline, offer ADRs, and visualise with Mermaid Sequence Diagrams (see `DIAGRAMS.md` for details).
4. You **MUST** always stick to the reply format shown in [EXAMPLES.md](EXAMPLES.md). Scenarios on each pass is a must. Keep the text concise, unless told to go into more details by the user. Technical jargon holds no value in alignment session. Every choice of wording is vitally important, you are a guide to ensure the user is well-equipped whilst you pair through discovery. Conciseness and clarity wins over verbosity. 
5. Alignment loops have multiple passes. A _pass_ is a _session_, make the decision together during the pass if it should be recorded then picked up in a new pass later with rationale. This could be context window _dumb zone_, waiting on dependencies, user request, etc. 
6. Run `/codebase-design` to explore with the user interface design, deep module names, agreements using mermaid sequence diagrams. The user wants to be involved in this layer. 

**Pass 1 on a placeholder.** A ticket queued by `/triage` carries no `Passes:` header — the shape is in [EXAMPLES.md](EXAMPLES.md). The first pass folds its Triage notes into Background, then writes the header and the rest of the rows.

## At session close - route the output
An alignment is a _thinking_ artefact, not by default a spec or a build. The close has four exits — `needs-alignment`, `needs-info`, `ready-to-cut`, `ready-to-build` — and the row it takes is read from the body, never guessed from the conversation. The routes are:

| the pass ends on | Verdict | Destination | Ticket state | Next |
| --- | --- | --- | --- | --- |
| the body already carries the contract | aligned | `tickets` | `ready-to-build` | `/build` |
| the contract is settled but the cut is owed | aligned | `tickets` | `ready-to-cut` | `/cut` → one ticket, or slice tickets at `ready-to-build` → `/build` |
| a yes is owed outside the room | aligned | `proposal` | `needs-info` | `/propose` → `awaiting-decision` → yes: `ready-to-cut` · change: `needs-alignment` with the objections · no: `wontfix` |
| the deliverable is the decision itself | aligned | ADR, or nothing | none — the ticket closes | write the ADR, update `CONTEXT.md`, stop |
| decisions still open | fog | unchanged | `needs-alignment` | `/align <ref>` again — every unresolved item carries the route that would settle it |
| unresolved items with no route, axes unmarked, or no decisions recorded | thin | unchanged | `needs-alignment` | record what is missing, then `/align <ref>` |
| what is open is a fact, not a decision | fog | unchanged | `needs-info` | clear the fact (`/research`, a sub-agent, the vendor's docs), then `/align <ref>` |
| the work is not worth doing | dropped | nothing | none — the ticket closes | record the reason in one paragraph, close `wontfix` where a ticket exists, stop |

**The close writes three things and refuses more**: the ticket's body and its pass comment, the ADR where one is owed, and `CONTEXT.md` inline. The pass preps work, it does not execute it — the files a ticket delivers land after the cut and the readiness check. A route answer is never write permission: `/align` creates no node on its own, and no node is written without its body shown and confirmed first.

The body carries the pass count, the verdict, the destination, what the pass was verified against, the unresolved items with their routes, and the next act. A pass comment carries only what moved in that pass.

A contract that graduates to `ready-to-build` at the close passes the ten rows in [READINESS.md](../cut/READINESS.md) first; a failed row keeps the work at `needs-alignment` with the row named.

## Additional Files
**Examples**: See [EXAMPLES.md](EXAMPLES.md)
