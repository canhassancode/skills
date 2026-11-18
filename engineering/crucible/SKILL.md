---
name: crucible
description: Review a diff against its spec and the user's rules. It checks each acceptance criterion, walks the changed hunks for failure paths and probes any boundary they touch, checks CLAUDE.md rules, greps the consumers of what changed and reads claims against the diff. It mutates the changed lines only when a fix carries no test. Returns findings; never edits the caller's tree or posts. Use when /build vets its branch, or /review and /shepherd analyse a pull request.
argument-hint: <base>...<head> [ticket ref]
---

# Crucible

Say what in a diff is wrong, missing or unproven, with evidence a reader can rerun.

Origin: Pocock's code-review (a spec axis that quotes each line; "sub-agent output is a hypothesis"; never rerun until clean, "because it never will") and Google's diff-scoped mutation testing (Petrović et al. 2021).

Findings are about correctness, the spec and the user's written rules, not taste. A reviewer asked to find gaps "will usually report some" even when the work is sound. The spec is the ticket's body. It is optional: without one, the spec step says so and the rest run.

## Steps

1. **Spec.** Quote each acceptance criterion and say whether the diff makes it hold, holds it partly, leaves it missing, or gets it wrong. Cite the test or the code that shows it. Then list what the diff does that the spec doesn't ask for. A criterion whose test was weakened or deleted is a finding.
2. **Walk** every changed hunk that writes, calls out, loops over outside data or shares a key, against the Correctness list in [BASELINES.md](BASELINES.md). Include the inputs production can send that the tests don't. A case that is safe is a note citing the line that makes it safe.
3. **Probe any boundary** the diff adds or loosens: a sandbox, a permission, an allowlist, a redaction. List everything that can cross it, then try a sample of the riskiest by driving the mechanism directly with its CLI or library. Never ask an agent to attack it, because it can refuse. Each crossing is a finding, with the command and its output.
4. **Rules.** Check the changed lines against the global and repo `CLAUDE.md`, then BASELINES.md. A broken `CLAUDE.md` rule is a finding; a baseline smell is a note. Skip what lint and the typechecker already enforce.
5. **Consumers.** For each changed export, type, field, default or behaviour, grep its callers and the prose that describes it. Do the same in each sibling repo the spec names that is checked out beside this one. A site the change broke is a finding. A new call to an existing function that drops an option or gate its other callers pass is a finding. A named sibling that isn't checked out is a note: `consumers: <repo> not checked`.
6. **Claims.**
   - Read each sentence of the pull request body or commit subject that says what the change does against the whole diff. One the diff doesn't bear out is a finding.
   - A hunk that leans on a production fact the spec marks `unchecked`, or doesn't carry at all, is a finding too: name the read that would settle it. Never run a production read yourself.
7. **Mutate, only when it pays.** Run it when a `fix:` commit in the range adds no test, or when the diff adds tests whose worth is in doubt. Follow [references/mutation.md](references/mutation.md), in a throwaway worktree, on the changed lines only. A mutant that no test kills, on a line a fix changed, is a finding: the fix is untested. Otherwise record `mutation: skipped — <why>`.
8. **Suppress** anything the spec's Out of scope or Decisions already settles, or that the caller's threads have settled, and cite it.
9. **Return**, using the format below.

## Return

```text
Spec        <n> of <n> criteria hold · <criterion, word for word> — partial | missing | wrong, <file:line>
            beyond the spec: <what>, <file:line>      (or: none)
Mutation    <killed>/<total> on fix lines, <minutes> min | skipped — <why>
Prune       <test file › name> — kills nothing unique    (or: none)

Findings, each:
  class     spec | behaviour | boundary | claim | rule
  at        file:line
  question  one sentence
  evidence  the command and its output, the grep hits, or the rule quoted
  route     fix | spec-change | product-call — <safe default> | suppressed — <source>

Notes       <case> → <file:line that handles it>; shape smells, each citing its baseline
```

`fix` is the caller's to act on. `spec-change` means acting would change a criterion, so it goes to `/align`. `product-call` is the user's decision.

The caller runs crucible at most twice on a branch: once over the whole diff, and once over the fix commits. A pass gives leads, not a verdict.
