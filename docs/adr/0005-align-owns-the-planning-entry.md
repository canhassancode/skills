---
status: accepted
---

# `/align` owns the planning entry and the alignment state

Supersedes [ADR-0002](./0002-triage-free-planning-lane.md)'s *by construction* claim.

## Context

ADR-0002 made the planning lane triage-free: `/to-spec`, `/to-tickets` and `/grill-with-docs` publish `ready-for-agent` **by construction**, so no planned ticket ever waits in an intermediate state. Upstream's v1.1.0 move then extracted `grilling` as a shared primitive and made `grill-me` and `grill-with-docs` compositions over it — deduplication, not deletion, and the family is roughly the same size as before.

The construction guarantee held. The artefact was thin anyway. Four failure modes, all observed in use:

- **The interview is not aimed at anything.** `grilling` resolves a decision tree in the abstract. It never asks what the interface is, what the sequence does, or whether the domain model has a word for this — so the session closes on shared understanding that does not survive being written down.
- **Nothing survives the session.** Decisions live in scrollback. A requirement change three weeks later re-asks everything from the start.
- **`ready-for-agent` was a promise about the label, not the ticket.** A ticket can be published by construction and still name no interface, no scenario and no out-of-scope list — and the agent that picks it up invents all three.
- **Fog had a separate apparatus.** `/wayfinder` charted investigation tickets for work whose questions were unknown. A map of unanswered questions is an unanswered-question list; it does not need its own tracker nodes.

## Decision

**`/align` is the planning lane's entry, its only mode, and the owner of the alignment state.**

- **`/align` supersedes `grilling`, `grill-me` and `grill-with-docs`.** The interview loop is retained intact — one question at a time, facts looked up rather than asked, decisions kept with the operator. What changes is that it is aimed at something: each question is woven through a named **Scenario**, carries a recommendation and a plain-English reason, and the session leaves an artefact.
- **`needs-alignment` is a real intermediate state, and the by-construction guarantee ends.** A ticket born from `/align` exists on the board before it is buildable, so the label is the guardrail that stops it being taken: it means **the body is not yet the contract**. Stage 2 rewrites the body as the fact and leaves the comments as the record of decisions. `/align` does not create that ticket on entry — it creates one only on the operator's word — so an alignment that closes **dropped**, or that is still foggy, leaves no tracker node behind.
- **A pass closes with a verdict, not a feeling.** Aligned (gate met, unresolved at zero → stage 2), fog (every unresolved item carries a route → another pass, and the routes are the plan), dropped (the work is not worth doing → no ticket, no further pass), or thin (unresolved without routes, axes unmarked, no decisions recorded → the failure). Fog and thin look identical from outside; the route is the discriminator. A dropped pass records its reason, so the decision is not re-opened.
- **The artefact is the deliverable, and it is plain text.** Sequence diagrams (`autonumber`, participants declared by **DDD role** and resolved against `CONTEXT.md`), state diagrams, sketch-to-settled interfaces, a deep-module table, decisions with their rejected alternatives, and an unresolved list that counts to zero. All of it renders on the trackers and diffs between passes.
- **Slices are vertical, layers are horizontal.** Stage 1 cuts slices (scope); stage 3 cuts layers (code). A layer is a branch and a pull request, never a tracker node — a horizontal layer is green but not independently valuable, so a ticket for one could never be honestly closed.
- **The four-pass discipline is `/align`'s.** The term keeps its content and changes its owner.
- **`gh stack` carries the change.** The base layer is `docs/` — the ADR, `CONTEXT.md`, research; layers above carry work. Branch names are semantic: `docs/`, `feat/`, `fix/`.

## Considered options

- **Keep `grilling` as the shared primitive and retarget only the compositions** — rejected. The primitive is what fails. An interview with no target produces shared understanding, and shared understanding is not an artefact.
- **Keep `needs-triage` as the intermediate state** — rejected. Triage classifies *inbound* work that arrived without a decision behind it. Alignment-born tickets arrive with the decision in progress, and sharing the vocabulary would make the two lanes indistinguishable in exactly the query that matters.
- **`discovery` as the label** — rejected. `/wayfinder` owns discovery in this vocabulary, and a label naming a phase says nothing about what a reader should do with the ticket.
- **Sub-issues, one per slice** — rejected. Sub-issues nest the workflow labels a level down, so `ready-for-agent` on a parent and on a child become different claims wearing one label, and *what can an agent take now* stops being one flat query. Slices are top-level issues linked by native blocking edges.
- **Sub-issues, one per horizontal layer** — rejected. A tracker node promises doable and closable on its own, which a horizontal layer never is.
- **Retire `/wayfinder` here** — rejected. Its fog-charting territory is what `/align`'s unresolved list replaces, but it is **Synced** with upstream and retiring it is a separate decision from retargeting the grilling family. Its `/grilling` references move to `/align`; nothing else changes.

## Consequences

- **A ticket can be seen before it is ready, deliberately.** A new intermediate state on the board is traded against agents inventing interfaces. The label, not the lane, carries the guarantee.
- **`/align` is multi-pass, and a pass is the unit of work.** A clear idea reaches a contract in one pass; a foggy one takes several. The artefact advances, not the session count.
- **Stage 2 is not designed here.** Whatever publishes the contract reads the artefact. Open: whether it subsumes `/to-spec` and `/to-tickets` or sits beside them.
- **The coach posture is rejected; the coach repertoire is taken.** From the two coach skills come the anti-pattern table (pattern → what it looks like → the question) and the context gate before asking anything. Not their refusal to produce deliverables — that is the guidance this ADR corrects.
- **The grilling skills stay in place while `/align` earns its keep.** Their deprecation and the reference updates across the library are a follow-up rather than part of this decision, so the meantime carries two ways into the same conversation. The cost is accepted deliberately: `/align` can be reverted without untangling a deprecation first.
