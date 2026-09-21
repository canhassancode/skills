---
name: align
description: Accepting a users new feature, requirements, general idea, ticket, PR comments and challenging against the existing domain, sharpening terminology, and making updates to artefacts and documentation (CONTEXT.md, ADRs, Sequence Diagrams). Use when users want to stress-test and align on their project's language and documented decisions.
argument-hint: <new feature | ticket-ref | requirements | pr comments | general idea>
---

## Procedure

1. Run `/grilling` for the interview loop.
2. Define up front what the intention appears to be. If a user wants to build a new feature, align upfront on the intention. If a user wants help fixing a bug or understanding PR comments, say this openly before proceeding. This helps with alignment with the user.
3. Fan-out to subagents upfront, gather details from relevant sources. **Do not** reply to the user with questions or anything further until all initial research has been gathered.
4. Combine with running `/domain-modeling` for domain work - challenge against the glossary, sharpen fuzzy language, stress-test with scenarios, cross-reference against code, update `CONTEXT.md` inline, offer ADRs, and visualise with Mermaid Sequence Diagrams (see `DOCS.md` for details on all 3).
5. Scenarios on each pass is a must. Keep the text concise, unless told to go into more details by the user. Technical jargon holds no value in alignment session. Every choice of wording is vitally important, you are a guide to ensure the user is well-equipped whilst you pair through discovery.
6. There will be multiple rounds in the loop. An example round looks like this:

```
## Scenario:
A customer checks out a basket. Today's API service creates orders and takes no payment; the payment part is new. First walk: a customer pays by card and the order lands in `paid`.

## Question:
Does the API service keep its own copy of payment status, or is the payment service the single source of truth that the API service reads through?

## Choices A-N:
- **A.** API service stores a `payment_status` column, updated from the provider's webhook.
- **B.** API service stores only `payment_intent_id` and reads status from the payment service on each request.
- **C.** Payment service owns an `orders` mirror; anything payment-shaped is read from there.
- **D.** API service holds no payment state at all; the client polls the payment service directly.
- **E.** API service stores the id plus a cached status with a short TTL, refreshed lazily on read.
- **F.** Undecided — the decision cannot be taken before the provider is chosen.

## Recommendation:
**B**, with E as the upgrade if list endpoints get slow. One source of truth means a status can never be quietly wrong; a mirror is a second copy that drifts the first time a webhook is missed, and nobody has scheduled the job that would notice.

## Other notes
The choice is not free either way: B puts the payment service on the critical path of every order read, so when it is down, order reads fail. If that trade is unacceptable, A moves the failure to "status is stale" instead of "status is unavailable" — but then a reconciliation task must exist, and it is the unresolved row this round opens: *who reconciles after a webhook never arrives, and when? → resolve by checking the provider's webhook retry window, then killing the listener in staging and waiting it out.*

```
7. Run `/codebase-design` after the domain has been decided to explore interface design, deep module names, agreements using mermaid sequence diagrams.

## At session close - route the output
An allignment is a _thinking_ artefact, it is **not** by default a spec/build. Session closes can be invoked by the user, it could be due to a large context window over _150k_, or when every branch in the design tree has been closed.


An alignment is a _thinking_ artefact, not by default a spec or a build. The close writes two things into the artefact header — the **Verdict** and the **Destination** — and the destination is what stage 2 reads.

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
