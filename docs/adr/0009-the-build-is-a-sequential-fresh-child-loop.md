---
status: accepted
---

# The build is a sequential fresh-child loop, and crucible is the only review policy

Supersedes [ADR-0007](./0007-align-build-and-one-review-policy.md) in part: its `/build` shapes — direct
and layered — and its three seats. Fires ADR-0007's own deferred trigger: `/code-review` retires.

## Context

Stage 3's two skills never ran. `/build` was invoked twice, both on itself, and stopped at its first
builder brief; `/crucible` has zero invocations across 98 repo sessions. The layer, seat and stack
apparatus was built for a need that has not appeared, and the loop it wrapped — one context carrying
contract, code, diffs, review and fixes — is what produced 250k-token sessions that skipped criteria.

The harness is now a fact rather than an assumption. pi spawns fresh, write-capable children today
(`subagent` with `delegate`), fans out to 20 concurrent children per run, and can isolate workflow
children in worktrees; Claude Code binds custom agents by `agentType` with tool allowlists, per-call
models and worktree isolation. Neither needs a parent that builds.

The review sample is also a fact. Across 40 real findings in 22 work PRs, 39 are contract-versus-behaviour,
one structural, none Standards or Design; `/code-review`'s four briefs plausibly reach 32 of them, and
crucible's procedure reaches the 8 they miss — six claim divergences through the consumer grep, two test
defects through its test class. Six of the 32 were withdrawn as false positives, which is what suppression
is for. The baselines those axes carried already live in `engineering/crucible/BASELINES.md`.

## Decision

**`/build` is one branch, a sequential loop of fresh-child units.** The Delegator holds the contract and
the run's one comment, never a diff. A unit is cut by criterion-coherence — a criterion or a coherent
group — and built by one fresh child that TDDs, commits on a real green and leaves the tree clean.
Crucible runs in its own fresh child between units; findings route to a fresh fix child, two rounds at
most. The window is a stop-rule: when it fills, what is green is committed, the comment records the
resume point, and a fresh session continues. One writer per checkout, always. Layers, seats and stacks
retire; a ticket that will not fit one session is cut finer, not rebuilt around.

**There is one mode.** Subagents unavailable is an unavailable dependency: the fit names it and the run
stops before writing. The parent does not build, and review is never self-review.

**`/crucible` is the only review policy.** `/code-review` deprecates into it — a redirect stub, out of the
plugin registry, a README deprecated row. `/review` invokes crucible as its engine and owns what crucible
refuses: resolving the pull request, checking it out, the voice, the reconciliation and the posting.
Crucible takes a diff range, the contract and the settled threads, and returns findings with evidence
plus the verified list.

**The eval scores coverage.** The 40-finding sample is mapped to the crucible step that would raise each,
hit or miss; the live replay belongs to the work seat.

## Considered options

- **Keeping the in-session and self-review seats** — rejected: the long window is the failure being
  closed, and a foreground child already streams into the operator's session for watching.
- **Fanning out across units** — rejected: units are dependency-ordered, and parallelism buys wall-clock
  at the cost of a worktree, a merge order and a conflict story per unit.
- **Absorbing crucible's procedure into `/review`** — rejected: `/build` needs the same procedure per
  unit, and `/review` is PR-shaped and hidden from the model.
- **Keeping `/code-review` beside crucible** — rejected: the baselines live in one file now, and two
  copies of the same axes drift. "Review since X" survives because crucible reviews a diff with no
  contract and names the gate that did not run.

## Consequences

- `CONTEXT.md` loses **Layer** and **Stack**; **Build** and **Builder** are rewritten around the unit,
  and a new **Unit** term carries the quantum.
- `/build/SKILL.md` and `/crucible/SKILL.md` are rewritten under the platform best-practices regime; the
  separate fit, plan and layer records become one session comment.
- `/implement` retires once `/build` has run a real build; `/code-review` retires now.
- Coverage is not parity: the eval says which classes crucible reaches, not that it matches Greptile's rate.
