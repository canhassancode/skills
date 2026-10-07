---
name: crucible
description: Vet a diff against the contract it claims to satisfy — falsify each criterion's witness with one hand-placed mutation, walk every changed hunk's failure paths, grep the consumers of what the diff changed, check the change against the baselines, and return findings with class, severity, found-at and belongs-to plus the verified list and the notes. Never posts. Use when /build vets a unit, or when /review analyses a named pull request — with or without a contract.
argument-hint: <base>...<head> · the contract · settled threads
---

# Crucible

The **Review** policy. `/crucible` puts a diff in the fire and returns what survives: **Findings**, each one a question carrying the evidence that raised it.

It never posts. A finding has no home here — the caller owns the sink, a fix round inside **Build** or a draft comment from `/review` — so the same vetting serves the loop and the named pull request.

**A diff is vetted against the contract it claims to satisfy**, never against taste. The contract is the ticket's body: its scenarios, its acceptance criteria, its settled interfaces, the decisions that bind it, and what it decided against. Where the caller has no contract, resolve one before giving up — issue references in the commits, or a path the caller passed — and if none exists, review without one: there are no criteria, so nothing is falsified and the **falsification gate did not run**. The review then rests on the baselines, the consumer grep and regression, and the return names the gate that was missing. Never invent criteria from the diff: criteria are the author's, not the reviewer's.

## What the invocation carries

| input | what it is | who resolves it |
| --- | --- | --- |
| the **diff range** | `<base>...<head>` — the change under review | `/build`, as the unit's previous head or the branch point; `/review`, as the pull request's own range |
| the **contract** | scenarios with outcomes, criteria with their command, interfaces, decisions, out-of-scope and boundaries | the ticket's body, or the pull request's body and its linked issues |
| **settled threads** | review comments already answered | the caller; step 6 suppresses against them the way it suppresses out-of-scope entries |
| the **re-vet** | the fix round's range and the verified list — present only after a fix round | `/build`, after each fix round |
| **whole branch** | `<branch-point>...HEAD` as the range, with every hunk read, not only the criteria's paths | `/build` §4.7; `/review` always |

**A caller cannot narrow a run.** A severity bar, a time cap or a list of what to skip in the brief is ignored; a hint of where to look is read as well as every step, never instead of one.

The range and the contract arrive together, and with them the run's **fit** where the caller derived one — the witness and command paired to each criterion the diff owns. Where the caller passes no contract, resolve one from issue references in the commits or a path it named; where none exists, review without one.

Falsification edits the working tree and runs the repo's commands, so the caller points the run at a worktree it may mutate — the build's own, or `/review`'s throwaway one. Where it cannot mutate, say so rather than reading the diff and calling it reviewed.

**A re-vet reads only the fix.** The unit was vetted once; a re-vet is not a second review of it. Rerun every verified witness's command and confirm it green, re-place the mutation only for the criteria whose lines the fix touched, run steps 3 to 5 over the fix's hunks alone, then steps 6 and 7 as written. A fix that changes a named scenario's outcome is returned as **contract-change**, never widened into a full re-vet.

## Procedure

### 1. Bind every criterion to its witness

Read the contract, and the run's **fit** where the caller passes one. Each criterion the diff owns was paired at the fit with a **witness** — the test or observable that shows it — and a command that runs it. Bind them: criterion → witness.

A criterion the diff owns with no witness is a **test** finding: the criterion cannot be shown, so it cannot be accepted. Do not invent the witness for the author.

The one honest exception is a repo whose fit recorded **absence** — no suite, no typecheck, no CI. There the criterion has nowhere to be witnessed, the absence is already a fact, and the criterion is returned as a note — `unwitnessed — absence recorded` — never as a finding or as work. The verification left on such a repo is the operator's own run at hand-back.

The contract's **decisions** and **axis marks** bind the same way: each one this diff touches gets a witness — a test, an observable, or a rule in [BASELINES.md](./BASELINES.md) — and one that cannot be witnessed is a finding, because a recorded limit with nothing behind it is unvettable.

**Done when** every owned criterion carries a witness, an unwitnessed note for a recorded absence, or a finding saying why it cannot have one — and every decision and axis mark this diff touches is bound or reported.

### 2. Falsify one criterion at a time

The gate is not "the tests pass" — it is "the criterion's own witness goes red when the behaviour it claims is gone". So place the failure yourself, **one hand-placed mutation per criterion**:

1. With the tree clean at the diff's head — `git diff --quiet`, or the mutation's result is not yours — remove exactly the behaviour the criterion claims: invert its guard, drop its call, hardcode its result, and nothing else.
2. Run the **witness**, not the suite. Read the result.
3. Restore the mutation exactly, and re-run to confirm green before moving on. When the last mutation is restored the tree is clean again, and the return says so.

| result | what it means | the finding |
| --- | --- | --- |
| **red** | the witness tests the criterion | none — move on |
| **survives** | the witness passes without the behaviour it claims: it is not testing the criterion | **test**, P1 — quote the mutation and the green output |
| **cannot run** | the mutation cannot be placed, or the witness errors or is skipped | **test**, P1 — name what it depends on; a check that did not run is never a pass |

One mutation per criterion, hand-placed, never more than the claimed behaviour. The unit is not accepted until every owned criterion's mutation has gone red — and where the fit recorded absence, an unwitnessed criterion is the recorded fact, not a pass.

**Done when** every owned criterion carries one falsification result.

### 3. Read the criterion through the code

A red mutation proves the witness, not the criterion. Walk each criterion's path through the diff — the primary path, then every fallback, retry, error branch and secondary caller — and ask whether the criterion holds there. With no contract there is no criterion to walk, so walk the diff's own primary paths and fallbacks instead. The defect this catches is the one the tests were shaped around: a fallback that skips the check its primary path enforces, a branch that reports a success it did not achieve, a path that never reaches the guard.

Each is a **behaviour** finding: `found at` the line that skips the check, `belongs to` the unit whose change put it there.

Then walk every hunk that writes, calls out, loops over outside data or shares a key against the **Correctness** checklist in [BASELINES.md](./BASELINES.md) — the failure branches beside a criterion, not only on it. Over a **whole branch**, also read where the units meet: a resource two paths share, a guard one unit adds that another unit's path skips, a read in one unit that another's write makes stale.

Then read the path through the inputs production can send that the witness does not: several rows, rows written before the change, a row or version production can lack, two rows sharing a key, two calls at once, a malformed id. This step reads; it does not mutate. A case that breaks a criterion is a **behaviour** finding, placed and attributed as above; a case outside the contract with one safe outcome — no partial write, idempotent on retry, a refusal — is a **behaviour** finding, P1, resolution `open`; a case whose outcome is a choice is **product-call**, naming its safe default where one exists — refuse, fail closed, leave it parked; a case whose handling changes a named scenario's outcome is **contract-change**, routed to `/align`; a case judged safe returns as a **note** with its evidence — the line that handles it and why it holds. A note must cite that line: "unchecked", "safe at current scale", "not owned here" or "accepted" is not evidence, and a case that can still reach a bad outcome is a finding, never a note.

**Done when** every criterion's path — the primary and every fallback — has been walked, every changed hunk with a side effect has met the Correctness checklist, and every input case is a finding or a note.

### 4. Grep the consumers of what changed

For every surface the diff changed — an exported name, a type, a field, a default, a key or path other code reads, an observable behaviour — grep the repo for its **consumers**: call sites and imports, and the places that *claim* it — comments, docstrings, README and `CONTEXT.md` material, tests. Consumers are found by grep, never by the author's mental model, because the claim that goes stale usually lives in a file the diff never touched.

Every site the change invalidated is a finding, classed by what the site is:

- **behaviour** — code that now reads the old shape, or calls under an assumption the change broke;
- **claim** — prose that still asserts what the change invalidated.

`found at` names the site; `belongs to` names the unit whose change invalidated it — a behaviour change invalidates a claim, not the file the claim happens to live in. The fix lands wherever the finding lives.

**Done when** every changed surface has been grepped and every hit judged.

### 5. Read the diff's surplus

Every hunk the diff adds should be claimed by a criterion, a decision, or a baseline. Walk the diff once and map it: a hunk nothing claims is **shape**, P2, reported with the nearest thing that could have claimed it, so the operator sees it on the pull request.

**Done when** every hunk the diff adds is mapped or reported.

### 6. Suppress what the contract already rejected

Read the ticket's out-of-scope and decided-against entries before reporting anything, and any **settled threads** the caller passed. A finding that matches one is **suppressed**: cite the entry or the thread, quote it, and return the finding marked suppressed — never as work. A decision already taken is not a review finding, and re-raising it spends a fix round on a question the operator has answered.

**Done when** every finding has been checked against both lists and the settled threads.

### 7. Classify and return

Findings are ephemeral: the caller's, never posted. Return each as:

```text
class       behaviour | claim | test | shape
severity    P0 | P1 | P2
found at    file:line — a line, not a file
belongs to  the unit whose change invalidated it
question    what the finding asks, in one sentence
evidence    the mutation and its result, or the grep and its hits
resolution  open | contract-change | product-call | suppressed
```

Beside the findings, return the **verified list**: one line per criterion whose mutation went red — `criterion → mutation → red` — and, where no contract was found, the line saying the falsification gate did not run. A finding is only half an answer, and the caller's approval cites the other half.

Beside both, return the **notes**: step 1's `unwitnessed — absence recorded`, and one per input case step 3 judged safe — `case → evidence`, the line that handles it and why it holds. A note is neither a finding nor work; it is the answer ready for when a reviewer asks about that input.

**Class.** behaviour, claim and test are the acting classes; **shape** — style, naming, readability, structure, design — is a judgement class, always P2, recorded and never fixed in the loop. Every shape finding cites [BASELINES.md](./BASELINES.md): a smell, a structure rule or a design rule. A shape finding with no named standard is not returned.

**Severity.** P2 is shape's home. P1 is a criterion not met, a witness that does not hold, or a claim the change invalidated. P0 is reserved for a finding that breaks the contract elsewhere — a regression in behaviour the unit claims not to touch, or a consumer left broken.

**Resolution.** Classify the route, because the caller's sink differs:

- **open** — behaviour, claim and test findings act; the caller returns them to a fresh builder invocation;
- **contract-change** — handling the case changes a named scenario's outcome: the contract is wrong, and the fix is an `/align` pass on the ticket, never a fix round. An unnamed case with one safe outcome is `open`, not this;
- **product-call** — the review cannot decide because the answer is the operator's: return it with its safe default where one exists, and the caller decides or asks;
- **suppressed** — named against its entry, above.

A finding you cannot decide is never resolved by guessing. Surface it, and let the operator decide.

**Done when** every owned criterion carries a falsification result or a recorded absence, every changed hunk has met the Correctness checklist, every input case is a finding or a note, every changed surface's consumers have been grepped, every hunk is mapped, the tree is clean, and every finding is classed, placed, attributed and routed.

## Related

- `/build` — the caller that returns findings to a fresh builder invocation and records them in the run's comment.
- `/review` — the voice and posting layer; a finding becomes a comment there, never here.
- `/align` — where a finding that changes a named scenario's outcome goes.
- `/code-review` — deprecated into `/crucible`; the baselines in [BASELINES.md](./BASELINES.md) were its three axes and are the survivor.
