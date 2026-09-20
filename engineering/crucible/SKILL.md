---
name: crucible
description: Vet a diff against the contract it claims to satisfy — falsify each criterion's witness with one hand-placed mutation, grep the consumers of what the diff changed, return findings with class, severity, found-at and belongs-to. Never posts. Use when /build vets a layer, when a whole stack is critiqued, or when /review needs a named pull request analysed.
argument-hint: <layer | stack | pull request>
---

# Crucible

The **Review** policy. `/crucible` puts a diff in the fire and returns what survives: **Findings**, each one a question carrying the evidence that raised it.

It never posts. A finding has no home here — the caller owns the sink, a fix round inside **Build** or a draft comment from `/review` — so the same vetting serves the loop and the named pull request.

**A diff is vetted against the contract it claims to satisfy**, never against taste. The contract is the ticket's body: its scenarios, its acceptance criteria and their classes, its settled interfaces, the decisions that bind it, and what it decided against. A diff with no contract stops here: there is nothing to falsify, and taste is not a standard.

## What the argument carries

| argument | resolve | the diff |
| --- | --- | --- |
| a **layer** — a branch and its base | the layer record on the ticket: `branch`, `base` | `git diff <base>...<branch>` |
| a **stack** — every layer of one ticket | the ticket's branches, from the layer records or `gh stack view --json` | `git diff <base of the bottom layer>...<tip of the top>` |
| a **pull request** | `gh pr view <ref> --json headRefOid,baseRefOid,body`, the head fetched into a throwaway worktree | the pull request's own range |

Falsification edits the working tree and runs the repo's commands, so run it somewhere a worktree may be mutated — the layer's checkout, or a disposable one for a pull request or a stack. Where it cannot mutate, say so rather than reading the diff and calling it reviewed.

## Procedure

### 1. Bind every criterion to its witness

Read the contract, and the run's **fit record** where one exists. Each criterion the diff owns was paired at the fit with a **witness** — the test or observable that shows it — and a command that runs it. Bind them: criterion → class → witness.

A criterion the diff owns with no witness is a **test** finding: the criterion cannot be shown, so it cannot be accepted. Do not invent the witness for the author.

The one honest exception is a repo whose fit recorded **absence** — no suite, no typecheck, no CI. There the criterion has nowhere to be witnessed, the absence is already a fact, and the criterion is returned as a note — `unwitnessed — absence recorded` — never as a finding or as work. The verification left on such a repo is the operator's own run at hand-back.

**Done when** every owned criterion carries a witness, an unwitnessed note for a recorded absence, or a finding saying why it cannot have one.

### 2. Falsify one criterion at a time

The gate is not "the tests pass" — it is "the criterion's own witness goes red when the behaviour it claims is gone". So place the failure yourself, **one hand-placed mutation per criterion**:

1. With the tree clean at the diff's head, remove exactly the behaviour the criterion claims — invert its guard, drop its call, hardcode its result — and nothing else.
2. Run the **witness**, not the suite. Read the result.
3. Restore the mutation exactly, and re-run to confirm green before moving on.

| result | what it means | the finding |
| --- | --- | --- |
| **red** | the witness tests the criterion | none — move on |
| **survives** | the witness passes without the behaviour it claims: it is not testing the criterion | **test**, P1 — quote the mutation and the green output |
| **cannot run** | the mutation cannot be placed, or the witness errors or is skipped | **test**, P1 — name what it depends on; a check that did not run is never a pass |

One mutation per criterion, hand-placed, never more than the claimed behaviour. The layer is not accepted until every owned criterion's mutation has gone red — and where the fit recorded absence, an unwitnessed criterion is the recorded fact, not a pass.

**Done when** every owned criterion carries one falsification result.

### 3. Read the criterion through the code

A red mutation proves the witness, not the criterion. Walk each criterion's path through the diff — the primary path, then every fallback, retry, error branch and secondary caller — and ask whether the criterion holds there. The defect this catches is the one the tests were shaped around: a fallback that skips the check its primary path enforces, a branch that reports a success it did not achieve, a path that never reaches the guard.

Each is a **behaviour** finding: `found at` the line that skips the check, `belongs to` the layer whose change put it there.

**Done when** every criterion's path — the primary and every fallback — has been walked.

### 4. Grep the consumers of what changed

For every surface the diff changed — an exported name, a type, a field, a default, an observable behaviour — grep the repo for its **consumers**: call sites and imports, and the places that *claim* it — comments, docstrings, README and `CONTEXT.md` material, tests. Consumers are found by grep, never by the author's mental model, because the claim that goes stale usually lives in a file the diff never touched.

Every site the change invalidated is a finding, classed by what the site is:

- **behaviour** — code that now reads the old shape, or calls under an assumption the change broke;
- **claim** — prose that still asserts what the change invalidated.

`found at` names the site; `belongs to` names the layer whose change invalidated it — a behaviour change invalidates a claim, not the file the claim happens to live in. The fix lands wherever the finding lives.

**Done when** every changed surface has been grepped and every hit judged.

### 5. Suppress what the contract already rejected

Read the ticket's out-of-scope and decided-against entries before reporting anything. A finding that matches one is **suppressed**: cite the entry, quote it, and return the finding marked suppressed — never as work. A decision already taken is not a review finding, and re-raising it spends a fix round on a question the operator has answered.

**Done when** every finding has been checked against both lists.

### 6. Classify and return

Findings are ephemeral: the caller's, never posted. Return each as:

```text
class       behaviour | claim | test | shape
severity    P0 | P1 | P2
found at    file:line — a line, not a file
belongs to  the layer whose change invalidated it
question    what the finding asks, in one sentence
evidence    the mutation and its result, or the grep and its hits
resolution  open | contract-change | product-call | suppressed
```

**Class.** behaviour, claim and test are the acting classes; **shape** — style, naming, readability — is a judgement class, always P2, and never stops a layer.

**Severity.** P2 is shape's home. P1 is a criterion not met, a witness that does not hold, or a claim the change invalidated. P0 is reserved for a finding that breaks the contract elsewhere — a regression in behaviour the layer claims not to touch, or a consumer left broken.

**Resolution.** Classify the route, because the caller's sink differs:

- **open** — behaviour, claim and test findings act; the caller returns them to a fresh builder invocation;
- **contract-change** — a scenario the contract never named: the contract is short, and the fix is an `/align` pass on the ticket, never a fix round;
- **product-call** — the review cannot decide because the answer is the operator's: surface it in session, and the parent records the answer as a decision row or an out-of-scope entry;
- **suppressed** — named against its entry, above.

A finding you cannot decide is never resolved by guessing. Surface it, and let the operator decide.

**Done when** every owned criterion carries a falsification result or a recorded absence, every changed surface's consumers have been grepped, and every finding is classed, placed, attributed and routed.

## Related

- `/build` — the caller that returns findings to a fresh builder invocation and records them on the layer.
- `/review` — the voice and posting layer; a finding becomes a comment there, never here.
- `/align` — where a finding that names a new scenario goes.
