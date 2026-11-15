---
name: align
description: Plan a change before it's built. Tier it, grill it in rounds, red-team any boundary it touches, and write the spec once from the conversation. Runs across several sessions when the ask is big or foggy. Use when the user brings a feature, ticket or idea to plan, or a ticket is needs-alignment.
argument-hint: <idea | ticket-ref>
disable-model-invocation: true
---

# Align

Turn an ask into a spec the build can work from cold: what to build, acceptance criteria, seams and Verify steps.

Origin: Pocock's grill-with-docs → to-spec (grill in rounds, write the glossary as you go, then synthesise the spec without re-interviewing) and Shape Up's shaping (appetite, no-gos and rabbit holes settled before the bet).

Questions follow [grilling](../grilling/SKILL.md), with each round shaped like [EXAMPLES.md](EXAMPLES.md#a-round). Terms and ADRs follow [domain-modeling](../domain-modeling/SKILL.md). Facts come from subagents, never from the user. Never open `.env`, `.mcp.json` or other config holding credentials.

## Steps

1. **Tier.** Place the ask on [references/tiers.md](references/tiers.md). Confirm it in the same message that lists the read-only routes this session has to where the change will run: the production database, its logs, each live supplier, each sibling repo checked out beside this one. Name any that are missing.
   - **One-sentence diff, or one or two files with nothing to decide:** say so, name the risk in one line, and stop. The change is made in an ordinary session and `/crucible` reviews it.
   - **Foggy:** send each unknown to [`/spike`](../spike/SKILL.md), [`/research`](../research/SKILL.md) or [`/prototype`](../prototype/SKILL.md), one question each, as a subagent. Carry on grilling around it.
   - **A ticket at `needs-alignment` from a cut:** read the parent spec and the ticket. Settle only the open question its body names, then go to step 5.
2. **Red team** with [references/red-team.md](references/red-team.md) in a fresh subagent. Show its verdict, and the user decides.
3. **Grill** in rounds until the frontier is empty.
   - **What someone will see is asked open.** A question about what a user, a caller or another system sees, or what gets stored, goes in its round as the scenario and the question alone, with no recommendation. Record the answer in the user's words. Recommend only on a technical choice nobody outside the code could notice.
   - **"I don't know" is not a yes.** Nor is "go with your recommendation" on what someone will see. Name who would know, and leave that question open for them.
   - **Seams.** Before the frontier closes, propose the fewest seams the criteria can be tested at, ideally one, preferring existing ones. Ask the seams as one question.
4. **Domain.** Write each resolved term to `CONTEXT.md` as it settles, and say so in one line. Offer an ADR only when it passes domain-modeling's three tests.
5. **Spec.** Write it once, from the conversation, in [references/spec.md](references/spec.md)'s shape: a child if it fits one fresh `/build` session, otherwise a parent. Below it, show [where each line came from](EXAMPLES.md#where-each-line-came-from): each criterion under the user's answer, a checked claim, or your call. Then put every call of yours, plus the yes on the whole spec, in one round.
6. **Close.** Write the spec into the ticket body, post one session comment, and set the label.

| Ends on | Label | Next |
|---|---|---|
| a child | `ready-to-build` | `/build <ref>` |
| a parent | `ready-to-cut` | `/cut <ref>` |
| a yes owed by someone outside the room | `ready-to-propose` | `/propose <ref>` |
| a question still open, or a session that ended early | `needs-alignment` | its route, then `/align <ref>` |
| no-go | `wontfix` | the reason, then stop |

## Across sessions

A big or foggy ask can run across several sessions. Grilling, spikes and research fill a window fast. Stop at a natural break, after a compaction, or when the user says it is getting long. Post a session comment shaped like [EXAMPLES.md](EXAMPLES.md#a-session-comment): what was decided, what is still open on the frontier, and a Resume line. Then tell the user to `/clear` and run `/align <ref>`.

A ticket whose last session comment ends in a Resume line starts from it. Read the body and the comments, ask nothing they already settle, and carry on from the open frontier. The spec is still written once, in the session where the frontier empties.
