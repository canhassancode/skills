---
status: proposed
---

# Locked tests replace the contract pipeline

## Context

`/align` → `/cut` → `/build` → `/crucible` ran the same ceremony for a one-line change as for a multi-session feature. Runs were long, the READINESS gate failed often, and most of the time went on process that yielded little. The contract was prose criteria with witnesses that crucible falsified after the fact.

Research run on 2026-10-26 (`docs/agent-skills-fundamentals-research.md` on its own branch, plus testing, spec-driven and delegation notes) points the other way: the oracle should be tests written from the spec before the code, by a context that never sees the implementation, and locked against the implementer.

## Decision

The four skills are rewritten from scratch; only the names are kept.

- **Planning scales with size and uncertainty.** A small, known change gets an issue and its tests; foggy work gets a spike, research or prototype first; large work gets a parent spec with children planned just in time.
- **Tests are the contract.** A new `/tester` writes acceptance, property, contract and end-to-end tests from the approved spec and interface, named by the spec's behaviour lines, proven red for the right reason, approved by the human and committed as `test: lock …`.
- **The lock is mechanical.** A global `PreToolUse` hook in `canhassancode/dotfiles` blocks edits as they happen; a check fails the branch if a locked file changed after the lock commit; the implementer's exit is to stop and report a test it believes is wrong.
- **Skill files are thin; references carry the substance.** `tester`'s references hold the principles and examples; the target repo's own conventions win over the examples, except the locked suffixes, behaviour-line titles and the `test: lock` commit.
- **Forge is out of scope** until the flow is proven by hand. It keeps running the old pipeline.

## Consequences

- `/build` no longer needs crucible's witness falsification. It keeps ADR-0009's sequential fresh-child loop, because a whole capability rarely fits one session's context, but a unit is now a group of locked tests and each commits on green. Crucible runs once over the branch: the lock check, mutation on the changed lines with a prune list of scratch tests that kill nothing unique, the correctness walk, `CLAUDE.md` rules and the consumer grep.
- Green tests aren't the whole of done. A child spec carries a `## Verify` section agreed at `/align`; a fresh verifier that never sees the code runs it on the app, and any step it can't run becomes an unchecked box in the pull request.
- Skills that reference the old four (`review`, `shepherd`, `propose`, `triage`, `bootstrap`, `diagnose`, `domain-modeling`) need repointing when the rewrite lands.
- `tdd` overlaps with `tester`'s references; decide whether it is deprecated once both are in use.
- Success is measured by the `evals/` suite and by running the flow on one small and one large real feature.

## Basis

- Independent, spec-first tests: TDFlow (94.3% vs 68.0%); independent tests caught faults 25% vs 14% (Konstantinou et al., 2026).
- Locking and the exit: ImpossibleBench (Zhong, Raghunathan & Carlini, ICLR 2026).
- Planning tiers: Claude Code's "if you could describe the diff in one sentence, skip the plan"; spikes from XP; appetite and no-gos from Shape Up.
