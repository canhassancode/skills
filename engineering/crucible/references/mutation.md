# Mutation on the diff

Mutate only lines the diff changed, in a worktree crucible owns. The kill data answers two questions. Is a fix actually tested? And which of the diff's new tests earn their place?

## The throwaway worktree

```sh
git worktree add --detach "$TMPDIR/crucible-<short-sha>" <head>
```

Install, mutate and run there. The caller's tree is never edited, so a mutation can't be left behind in it. Restore a mutant with `git show <head>:<file> > <file>`, which needs no git index. Finish with `git worktree remove --force "$TMPDIR/crucible-<short-sha>"`.

## The changed line ranges

```sh
git diff --unified=0 <base>...<head> -- . ':!*.test.*' ':!*.spec.*' ':!e2e/'
```

Each `@@ … +start,count @@` is a range `file:start-(start+count-1)`. Drop files that are config, types only or generated. When the reason to mutate is an untested fix, take only that fix commit's ranges.

## Placing mutants

Place at most one mutant per changed function, and 20 in total:

1. Remove one piece of behaviour the line carries: invert a condition, drop a call, return a constant, skip a write.
2. Run only the tests that cover the mutated file, with `timeout 120` and a reporter that names failing tests: `vitest related <file> --run --reporter=json`, `jest --findRelatedTests <file> --json`, or else the test files that import it.
3. Record which tests went red, then restore the file.

A test that fails without any mutant is flaky. Run it once more on the clean tree, and leave it out of the kill data if it fails again.

## Budget

Fifteen minutes per run. When the budget runs out, stop and name what was skipped in the Mutation line: a silent cap reads as full coverage.

## The keep rule

1. Start with the mutants killed by tests that existed before the diff.
2. Among the tests this diff added, pick the one that kills the most mutants not yet killed; keep it and add its kills. Repeat until no new test adds a kill.
3. Every new test not kept goes on the prune list, including those that kill nothing.

This only ever prunes the diff's own new tests. Cutting older tests permanently is how reduced suites came to miss real faults in up to 52% of failed builds (Shi et al., ISSTA 2018), so they stay.

## Evidence

- One mutant per changed, non-arid line: Petrović et al., *Practical Mutation Testing at Scale*, Google 2021, https://arxiv.org/abs/2102.11378. Google's developers first rated 85% of raw surfaced mutants unproductive, which is why survivors outside fix lines are not reported.
- Kill-based reduction loses no killed mutants; coverage-based loses up to 20.5%: Shi et al., FSE 2014.
- On brigade#136, five passes spent 16 of 45 agent-minutes on mutation. No finding came from mutation alone; it proved two fix commits were untested (ADR-0013).
