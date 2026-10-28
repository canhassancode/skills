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
   - A child of a cut parent: read the parent spec and skip to step 3.
2. **Red team.** Brief a fresh subagent with [references/red-team.md](references/red-team.md). Show its verdict — go, shrink or no-go — and the user decides.
3. **Spec.** Grill until [references/spec.md](references/spec.md)'s template is full: a child spec if it fits one session, otherwise a parent spec. Each settled question is a dated `Q → A` in Decisions.
4. **Domain.** Each new term and each ADR is its own yes.
5. **Interface** (child only). Propose signatures with [codebase-design](../codebase-design/SKILL.md): the code, one caller and the error kinds, one interface at a time. On a yes, commit them as stubs that compile and throw: `feat: stub <capability> interface`.
6. **Tests** (child only). Run `/tester` and show its report. An interface gap goes back to step 5. On a yes, commit `test: lock <capability> tests`.
7. **Close.** Check every number by [references/spec.md](references/spec.md)'s Numbers rule, then write the spec into the ticket body, push the branch if there is one, post the session comment and set the label.

| Ends on | Label | Next |
|---|---|---|
| a child with locked tests | `ready-to-build` | `/build <ref>` |
| a parent spec | `ready-to-cut` | `/cut <ref>` |
| a yes owed outside the room | `ready-to-propose` | `/propose <ref>` |
| a question still open | `needs-alignment`, naming it | its route, then `/align <ref>` |
| no-go | `wontfix` | the reason, then stop |

## Where it lives

- **Spec**: the ticket body, on the parent's ticket for a parent and on its own ticket for a child. It replaces whatever the body held. Status never goes in it; the label holds that.
- **Code** (child only): the stubs and locked tests on `feat/<capability>`, opened as a draft pull request that links the ticket. A child spanning repos names each repo's branch and the merge order in its header line, by [references/spec.md](references/spec.md). A parent has no branch.
- **Session comment**: one per session, carrying only what moved.

One child per session; the next starts fresh. A build that stops on a locked test comes back here: the spec changes first, the user removes the stale test, and step 6 runs for the changed lines only.
