---
name: crucible
description: Vet a diff — confirm locked tests are untouched, mutate only the changed lines to see which tests earn their place, look for code shaped to test inputs, walk changed hunks for failure paths, check CLAUDE.md rules and grep the consumers of what changed. Returns findings, a prune list and survivors; never edits the caller's tree or posts. Use when /build vets its branch, or /review and /shepherd analyse a pull request.
argument-hint: <base>...<head> [spec path]
---

# Crucible

Say what in a diff is wrong, unproven or unearned, with evidence a reader can rerun.

Origin: Google's diff-scoped mutation testing (Petrović et al. 2021: one mutant per changed line took useful mutants from 15% to 89%) and Shi et al. 2014 (pruning a suite by killed mutants loses no fault detection; by coverage, up to 20.5%).

Findings are about correctness, the spec and the user's written rules, not taste: a reviewer asked to find gaps "will usually report some" even when the work is sound. A spec is optional; without one, steps that need it say so and the rest run.

## Steps

1. **Lock.** Run [the lock check](../tester/scripts/check-locked-tests.sh) at the head. A changed locked file is a finding that blocks.
2. **Mutate the diff** in a throwaway worktree, never the caller's, as [references/mutation.md](references/mutation.md) says: Stryker over the changed line ranges, or hand-placed mutants, inside its budget. No runnable tests: record `mutation: absent — <why>`.
3. **Prune.** From the kill data, keep a scratch test only if it kills a mutant that the locked tests and the tests already kept miss. Every other test this diff added outside the locked files goes on the prune list. Locked tests and tests older than the diff are never listed.
4. **Survivors.** Each mutant on a changed line that no test kills is a question — is this behaviour the spec doesn't name? — never a test to write. Skip logging, config and messages.
5. **Shaped to the tests.** Look for code that branches on a locked test's fixture values or returns its expected outputs as literals. Each is a finding.
6. **Walk** every changed hunk that writes, calls out, loops over outside data or shares a key against the Correctness list in [BASELINES.md](BASELINES.md), and the inputs production can send that the tests don't. A case that is safe is a note citing the line that makes it safe.
7. **Rules.** Check changed lines against the global and repo `CLAUDE.md`, then BASELINES.md. A broken `CLAUDE.md` rule is a finding; a baseline smell is a note. Skip what lint and the typechecker already enforce.
8. **Consumers.** For each changed export, type, field, default or behaviour, grep its callers and the prose that describes it. A site the change broke is a finding.
9. **Suppress** anything the spec's Out of scope or Decisions already settled, or the caller's settled threads, citing it.
10. **Return**, using the format below. Remove the throwaway worktree.

## Return

```text
Lock        unchanged since <sha> | changed: <files>
Mutation    <killed>/<total> on changed lines, <tool>, <minutes> min | absent — <why> | budget hit — <what was skipped>
Prune       <test file › name> — no unique kill    (or: none)
Survivors   <file:line> <mutation> — <question>    (or: none)

Findings, each:
  class     behaviour | claim | rule | test
  at        file:line
  question  one sentence
  evidence  the mutant, command and output, grep hits, or the rule quoted
  route     fix | spec-change | product-call — <safe default> | suppressed — <source>

Notes       <case> → <file:line that handles it>; shape smells, each citing its baseline
```

`fix` is the caller's to act on. `spec-change` means acting would change a behaviour line, so it goes to `/align`. `product-call` is the user's decision.
