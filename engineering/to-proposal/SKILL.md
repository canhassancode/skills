---
name: to-proposal
description: Turn the current conversation (usually a grilling session) into a proposal aimed at a decision-maker, and publish it to Notion. Use when the output is an argued recommendation seeking buy-in — not a build spec. The proposal sibling of /to-spec.
disable-model-invocation: true
---

This skill takes the current conversation context and produces a **proposal** — an argued recommendation for a person to decide on, not a build spec for implementers. That's the line between this and `/to-spec`: a spec tells an implementer *what to build*; a proposal persuades a decision-maker *what to do and why*. Do NOT interview the user — synthesise what you already know from the grilling.

## Draft-first, publish-on-confirm

The proposal has two homes, deliberately:

1. **Draft in the vault** (`~/Obsidian/Employment/<employer>/` or the relevant Domain) at **B-private** fidelity — your full candid reasoning, including the file paths / SHAs / blunt assessments that informed it. This is your working artefact; it's encrypted and private.
2. **Publish to Notion on confirm** — render a cleaned proposal to the Notion proposals space via the Notion MCP. Crossing to Notion is an **audience pass**, not a confidentiality scrub: drop personal candour ("that estimate is fantasy" → "the 2-week estimate looks optimistic given X"), drop incidental paths/SHAs, and re-attach real customer identity here (Notion is the authorised surface where colleagues are entitled to it) from live context — never carried from the vault, where it's pseudonymised. Class A was never in the draft to strip.

If `~/Obsidian/` is absent, draft inline and skip step 1.

## Process

1. **Identify the audience and the ask.** Who decides — your manager, a stakeholder, a VP? How hard you argue and how much context you front-load depends on it. State the audience at the top of the draft. If unclear, ask the one question.
2. **Check for a house format.** Read the project/employer CLAUDE.md and any existing Notion proposals for a conventional shape; match it. Otherwise use the template below.
3. **Write the draft** in the vault (B-private), using the template.
4. **Confirm, then publish.** Show the cleaned (B-shared) version. On approval, create the Notion page via the MCP. Never publish without explicit approval — same gate as `/ingest`'s Employment review.
5. **Leave the ask outstanding on the artifact itself** — the vault draft records the recommendation and what is still owed by whom, and the Notion page carries it to the audience. There is no separate log.

## Proposal template

<proposal-template>

**Audience:** <who decides> · **Status:** <draft | shared | decided>

## Context

The situation and why it needs a decision now — from the decision-maker's perspective, not the engineer's.

## Options considered

Each option with a one-line characterisation. Include the do-nothing / status-quo option.

1. **<Option A>** — <what it is>
2. **<Option B>** — <what it is>

## Recommendation

The option you recommend, stated plainly up front, and the reasoning that makes it the right call.

## Trade-offs & risks

What the recommendation costs, what could go wrong, and what you'd accept to get its benefits. Name the trade-offs of the rejected options too — show the work.

## The ask

Exactly what you need from the reader: a decision, a sign-off, a resource, a date. Make it a single, answerable request.

</proposal-template>

## Related

- `/grill-with-docs`, `/grill-me` — the grilling this usually follows; their close-routing offers this skill.
- `/to-spec` — the sibling for build specs aimed at implementers (the tracker, not Notion).
