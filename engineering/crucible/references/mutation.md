# Mutation on the diff

Mutate only lines the diff changed, in a worktree crucible owns. The kill data answers two questions: do the tests notice when changed behaviour goes, and which of the diff's new scratch tests earn their place.

## The throwaway worktree

```sh
git worktree add --detach "$TMPDIR/crucible-<short-sha>" <head>
```

Install, mutate and run there. The caller's tree is never edited, so a mutation can't be left behind in it. Restore a hand-placed mutant with `git show <head>:<file> > <file>`, which needs no git index. Finish with `git worktree remove --force "$TMPDIR/crucible-<short-sha>"`.

## The changed line ranges

```sh
git diff --unified=0 <base>...<head> -- . ':!*.test.*' ':!*.spec.*' ':!e2e/'
```

Each `@@ … +start,count @@` is a range `file:start-(start+count-1)`. Drop files that are config, types only or generated.

## With Stryker

Where the repo has StrykerJS, write a config in the throwaway worktree only, so the repo's own is untouched:

```json
{
  "testRunner": "vitest",
  "disableBail": true,
  "reporters": ["json"],
  "incremental": true,
  "timeoutMS": 10000
}
```

```sh
timeout 900 npx stryker run crucible.stryker.json --mutate "src/shipping/index.ts:12-40,src/shipping/carrier.ts:5-18"
```

`disableBail` is what makes `killedBy` list every killing test, not just the first; without it, redundancy can't be measured. Read `reports/mutation/mutation.json`:

- `files[path].mutants[]`: `id`, `location`, `status`, `killedBy` (test ids)
- `testFiles[path].tests[]`: `id`, `name`

Count one mutant per changed line: where Stryker made several on a line, the line is killed if any was.

## Without Stryker

Hand-place mutants, at most one per changed function and 20 in total:

1. Remove one piece of behaviour the line carries: invert a condition, drop a call, return a constant, skip a write.
2. Run the repo's test command with `timeout 120`, using a reporter that names failing tests (`--reporter=json` in Vitest and Jest).
3. Record which tests went red, then restore the file.

## Budget

Fifteen minutes of mutation per run. When the budget runs out, stop and name what was skipped in the Mutation line: a silent cap reads as full coverage.

## The keep rule

1. Start with the mutants killed by locked tests and by tests that existed before the diff.
2. Among the scratch tests this diff added, pick the one that kills the most mutants not yet killed; keep it and add its kills. Repeat until no scratch test adds a kill.
3. Every scratch test not kept goes on the prune list, including those that kill nothing.

This only ever prunes the diff's own new tests. Cutting older tests permanently is how reduced suites came to miss real faults in up to 52% of failed builds (Shi et al., ISSTA 2018); they stay.

## Survivors

A survivor on a changed line is a question for the author, not an order to write a test. Google's developers first rated 85% of raw surfaced mutants unproductive, and tests written to kill those become change-detectors. Skip survivors in logging, messages, timeouts and config. One the author judges equivalent is noted as such.

## Evidence

- One mutant per changed, non-arid line: Petrović et al., *Practical Mutation Testing at Scale*, Google 2021, https://arxiv.org/abs/2102.11378.
- Kill-based reduction loses no killed mutants; coverage-based loses up to 20.5%: Shi et al., FSE 2014.
- Permanent reduction missed faults in up to 52.2% of failed builds: Shi et al., ISSTA 2018.
- `killedBy`, `disableBail`, `--mutate` ranges and `incremental`: StrykerJS configuration docs and report schema, read 2026-10-26.
- This library's own unbounded mutation runs held a machine for 17+ minutes and failed to restore through a read-only git index in 28% of sessions (forge audit, 2026-10-27).
