---
name: align
description: Plan a change before it's built — tier it, red-team it, agree a spec, approve its interface and lock its tests. Use when the user brings a feature, ticket or idea to plan, or a child ticket comes back for its interface and tests.
argument-hint: <idea | ticket-ref>
disable-model-invocation: true
---

# Align

Turn an ask into a spec, an approved interface and locked failing tests, so the build has nothing left to decide.

Origin: Shape Up's shaping (appetite, no-gos and rabbit holes settled before the bet) and Liu et al. 2026 (a reviewed plan helps; a poor plan does worse than none).

Every question follows [grilling](../grilling/SKILL.md). Every term and ADR follows [domain-modeling](../domain-modeling/SKILL.md). Facts come from subagents, never from the user, and every number follows [references/spec.md](references/spec.md)'s Numbers rule. Never open `.env`, `.mcp.json` or other config holding credentials, not even to find a connection. Every reply follows [EXAMPLES.md](EXAMPLES.md).

## Steps

1. **Tier.** Place the ask on [references/tiers.md](references/tiers.md) and confirm it.
   - One-sentence diff: say so, name the diff and any risk in one line each, and stop. Propose nothing: no aliases, shims or follow-ups.
   - Foggy: send each unknown to `/spike`, `/research` or `/prototype`, one question each. Log each answer in Decisions, then re-tier.
   - A child of a cut parent: read the parent spec and the child's body, then skip to step 3. The parent's Decisions and Rules and the body's Decisions are settled: never ask, re-derive or restate them. Check each against the code it touches. Code that breaks one today, or data showing it can't hold, goes back as [a challenge](EXAMPLES.md#a-challenge): the decision and its evidence's `file:line` in the same paragraph. Never change the decision silently. Your first message drafts every behaviour line the child needs to meet its goal and the parent's Rules and Journeys, then checks them against [references/tiers.md](references/tiers.md#size)'s size rule before any grilling question. Over it, that message proposes a split, its only question: the piece built first stays in this session, and the rest are listed with the command that publishes them, `/cut <parent-ref>`.
2. **Red team.** Brief a fresh subagent with [references/red-team.md](references/red-team.md). Show its verdict — go, shrink or no-go — and the user decides.
3. **Spec.** Grill until [references/spec.md](references/spec.md)'s template is full: a child spec if it fits one session, otherwise a parent spec. Write each settled answer into the ticket body's Decisions as a dated `Q → A` before you ask the next question, adding the section if the body has none: at the end of the body, or above `## Comments` where the tracker keeps one. The next question is one nothing settled yet: not in the parent's Decisions or Rules, nor in the body's Decisions.
4. **Domain.** Each new term and each ADR is its own yes.
5. **Interface** (child only). Propose signatures with [codebase-design](../codebase-design/SKILL.md): the code, one caller and the error kinds, one interface at a time. On a yes, commit them as stubs that compile and throw: `feat: stub <capability> interface`.
6. **Tests** (child only). Write the spec into the ticket body, then run `/tester` and show its report, its `Typecheck:` and `Gaps:` lines word for word. Every gap reaches the user in that same message, even when you then ask about one at a time. Any gap blocks the lock: an interface gap goes to step 5, a spec gap to step 3, and a green, stale-lock or typecheck gap to the user: for green, whether the line stays and what it should say; for a stale lock, removing it themselves (`! git rm <file>`) before the line is relocked; for a typecheck that couldn't run, usually installing dependencies and rerunning `/tester`. On a yes with no gaps, commit `test: lock <capability> tests`.
7. **Close.** Check every number by [references/spec.md](references/spec.md)'s Numbers rule, then write the spec into the ticket body, keeping every Decisions line it already held, push the branch if there is one, open its draft pull request as [EXAMPLES.md](EXAMPLES.md) does, post the session comment and set the label.

| Ends on | Label | Next |
|---|---|---|
| a child with locked tests | `ready-to-build` | `/build <ref>` |
| a parent spec | `ready-to-cut` | `/cut <ref>` |
| a yes owed outside the room | `ready-to-propose` | `/propose <ref>` |
| a question still open | `needs-alignment`, naming it | its route, then `/align <ref>` |
| no-go | `wontfix` | the reason, then stop |

## Where it lives

- **Spec**: the ticket body, on the parent's ticket for a parent and on its own ticket for a child. It replaces whatever the body held, except Decisions: each answer lands there as it is settled, and every rewrite keeps the lines already there. Status never goes in it; the label holds that.
- **Code** (child only): the stubs and locked tests on `feat/<capability>`, opened as a draft pull request that links the ticket. Its body is build's pull request filled in with what align knows: the goal, each behaviour line red at the lock, every Verify step as an unchecked box and the decided limits. Build updates it in place. A child spanning repos names each repo's branch and the merge order in its header line, by [references/spec.md](references/spec.md). A parent has no branch.
- **Session comment**: one per session, carrying only what moved.

One child per session; the next starts fresh. A build that stops on a locked test comes back here: the spec changes first, the user removes the stale test, and step 6 runs for the changed lines only.
