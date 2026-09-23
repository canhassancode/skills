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

**Pass 1 on a placeholder.** A ticket queued by `/triage` carries no `Passes:` header and three rows — Background, Problem statement, Triage notes. The first pass detects that shape, folds the notes into Background, and writes the header and rows as usual. A ticket whose body already carries the contract is not a placeholder: the pass updates it in place.

## At session close - route the output
An alignment is a _thinking_ artefact, not by default a spec or a build. The close has a few routes, see more details in the _Additional Files_ section. Some early examples of routes are:

| the pass ends on | Verdict | Destination | Ticket state | Next |
| --- | --- | --- | --- | --- |
| the tree is empty, one slice's worth | aligned | `tickets` | `ready-to-cut` | `/cut` → one ticket → `/build` |
| the tree is empty, more than one slice | aligned | `tickets` | `ready-to-cut` | `/cut` → slice tickets at `ready-to-build` → `/build` |
| the tree is empty, but a yes is owed outside the room | aligned | `proposal` | `ready-to-propose` | `/propose` → `awaiting-decision` → yes: `ready-to-cut` · change: `needs-alignment` with the objections · no: `wontfix` |
| the tree is empty and the deliverable is the decision itself | aligned | ADR, or nothing | closed, no node | write the ADR, update `CONTEXT.md`, stop |
| decisions still open | fog | unchanged | `needs-alignment` | `/align <ref>` again — every unresolved item carries the route that would settle it |
| what is open is a fact, not a decision | fog | unchanged | `needs-alignment` | clear the fact (`/research`, a sub-agent, the vendor's docs), then `/align <ref>` |
| the work is not worth doing | dropped | nothing | `wontfix` if a ticket exists, none if it does not | record the reason in one paragraph, stop |

Where the pass carries on, the row is the state change plus the pass comment; nothing else moves. Where a ticket has to be created for the next pass, the operator says so — `/align` does not create nodes on its own.

## Additional Files
**Examples**: See [EXAMPLES.md](EXAMPLES.md)
