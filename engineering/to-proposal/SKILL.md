---
name: to-proposal
description: Turn the current conversation (usually a grilling) into a proposal aimed at a decision-maker and publish it to the project tracker. The proposal sibling of /to-spec — an argued recommendation seeking buy-in, not a build spec.
disable-model-invocation: true
---

This skill takes the current conversation context and produces a **proposal** — an argued recommendation for a person to decide on, not a build spec for implementers. That's the line between this and `/to-spec`: a spec tells an implementer *what to build*; a proposal persuades a decision-maker *what to do and why*. Do NOT interview the user — synthesise what you already know from the grilling.

The issue tracker and triage label vocabulary should have been provided to you — run `/bootstrap` if not.

## Process

1. **Identify the audience and the ask.** Who decides — your manager, a stakeholder, a VP? How hard you argue and how much context you front-load depends on it. State the audience at the top of the draft. If unclear, ask the one question.

2. **Ask where it lands.** A proposal is a decision document, so its home differs from a spec's. Propose the tracker default and confirm:
   - **GitHub** → an **issue** labelled `ready-for-human` (a proposal is a request for a human decision — the same way `/to-spec` stamps `ready-for-agent` by construction).
   - **Linear** → a **Document** in an agreed location: an Initiative, a Project, or — if that's the agreed home — an issue labelled `ready-for-human`. Confirm which before publishing.
   - **No tracker adapter** (GitLab / local / other) → ask for a plain location, or draft inline and let the user place it.

3. **Check for a house format.** Read the project/employer `CLAUDE.md` and any existing proposals in that location for a conventional shape; match it. Otherwise use the template below.

4. **Write it for the audience.** Lead with the recommendation — the reader should know the ask before the reasoning. Concrete over hedged: real numbers, a before/after, and a snippet or diagram wherever it carries the argument better than prose. Human register — no throat-clearing ("it's worth noting…"), no AI hedging. Stay candid but audience-appropriate: sharpen private snark into a defensible judgement ("that estimate is fantasy" → "the 2-week estimate looks optimistic given X"), keep the judgement.

5. **Confirm, then publish.** Show the draft. On explicit approval, create it in the agreed location via the tracker adapter. Never publish without approval. The published artefact carries the ask outstanding — there is no separate log.

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

- `/grill-with-docs`, `/grill-me` — the grilling this usually follows; their close-routing offers this skill.
- `/to-spec` — the sibling for build specs aimed at implementers (a spec on the tracker; a proposal is the decision document beside it).
