---
name: propose
description: Turn an aligned spec into a proposal aimed at a decision-maker and publish it to the project tracker — the branch taken when work needs someone else's yes before it can go on. Use when a ticket sits at ready-to-propose, or when the operator asks for a proposal or a decision doc.
argument-hint: <ticket-ref>
disable-model-invocation: true
---

# Propose

The planning lane's one way of asking. Most alignments settle into work; some need someone else's yes first, and `/propose` is how that question gets asked well.

It reads the **spec** the ticket links, not a conversation. The goal, the behaviour lines, the decisions, the red team's verdict and the out-of-scope list are already the argument — the proposal's job is to retell it for a reader who was not in the room. Do NOT interview; synthesise.

A proposal is a request for a decision, not a build spec: a spec tells a builder *what to build*, a proposal persuades a decision-maker *what to do and why*.

Run it against a ticket at `ready-to-propose` — the state `/align`'s close sets when a yes is owed outside the room. A decision found while aligning never sets it on its own; only an ask that has to leave the room does.

The issue tracker and triage label vocabulary should have been provided to you — run `/bootstrap` if not.

## Procedure

1. **Read the spec and identify the ask.** Fetch the ticket through the tracker adapter and read the spec its body links. The Decisions entries are the options and their trade-offs, and the question the close named is what a yes would settle. Name the audience — your manager, a stakeholder, a client — because how hard to argue and how much context to front-load depends on them. If it is unclear, ask the one question.

2. **Ask where it lands.** A proposal is a decision document, so its home differs from a ticket's. Propose the tracker default and confirm:
   - **GitHub** → an **issue** (the decision doc, shared with whoever decides), or a comment on the ticket when the ask is small and the reader is already there.
   - **Linear** → a **Document** attached to the agreed Project or Initiative.
   - **No tracker adapter** (GitLab / local / other) → ask for a plain location, or draft inline and let the operator place it.

3. **Check for a house format.** Read the project/employer `CLAUDE.md` and any existing proposals in that location for a conventional shape; match it. Otherwise use the template below.

4. **Write it for the audience.** Lead with the recommendation — the reader should know the ask before the reasoning. Concrete over hedged: real numbers, a before/after, and a snippet or diagram from the body wherever it carries the argument better than prose. Human register — no throat-clearing ("it's worth noting…"), no AI hedging. Stay candid but audience-appropriate: sharpen private snark into a defensible judgement ("that estimate is fantasy" → "the 2-week estimate looks optimistic given X"), keep the judgement.

5. **Confirm, then publish.** Show the draft. On explicit approval, create it in the agreed location via the tracker adapter. Never publish without approval. The published artefact carries the ask outstanding — there is no separate log.

6. **Record the outcome.** Post one comment on the ticket linking the proposal, and move the ticket to `awaiting-decision` — the state belongs to the work, not to the document. When the answer arrives:
   - **Yes** → `needs-alignment`, with the answer posted on the ticket; `/align` logs it in Decisions and carries on from where it stopped.
   - **Change it** → `needs-alignment`, with the objections posted on the ticket so the next `/align` reads them rather than reconstructing them.
   - **No** → `wontfix`, with the reason recorded so the decision is not re-opened.

## Proposal template

<proposal-template>

**Audience:** <who decides> · **Decide by:** <date, or the cost of waiting> · **Status:** <draft | shared | decided>

**Bottom line:** one sentence — the recommendation and the ask — before any context.

## Context

The situation and why it needs a decision now — from the decision-maker's perspective, not the engineer's.

## Options considered

Each option with a one-line characterisation. Include the do-nothing / status-quo option.

1. **<Option A>** — <what it is>
2. **<Option B>** — <what it is>

## Recommendation

The option you recommend, stated plainly up front, and the reasoning that makes it the right call. Where code or a concrete artefact makes the case better than prose — a snippet, a benchmark, a before/after — inline the decision-rich part, not a working demo.

## Trade-offs & risks

What the recommendation costs, what could go wrong, and what you'd accept to get its benefits. Name the trade-offs of the rejected options too — show the work.

## Success metric

How you'll know it worked — the observable that tells a right decision from a wrong one. If none applies, say so rather than skip it.

## The ask

Exactly what you need from the reader: a decision, a sign-off, a resource, a date. Make it a single, answerable request.

</proposal-template>

## Related

- `/align` — whose spec this reads, whose close sets `ready-to-propose`, and where every answer goes back to.
