---
name: build
description: Stage 3 — build a cut ticket into layers, one fresh builder invocation each, every layer falsified by /crucible and pushed as its own branch in the ticket's stack. Use when a ticket sits at ready-to-build, or when the operator asks to build a ticket.
argument-hint: <ticket-ref>
disable-model-invocation: true
---

# Build

Stage 3. `/build <ticket-ref>` reads a cut **Ticket**'s contract, proves the repo's own loop, cuts the ticket into **Layers**, and builds them one at a time — each in a fresh **Builder** invocation, each vetted by `/crucible`, each pushed before the next begins. It hands back a stack of pushed branches, and no pull request.

The parent session owns the loop. It holds the **contract** and the **layer records**, never a diff: code in this window is cost the next layer cannot afford. Every Builder is **fresh** — a finding returns to a new invocation carrying the finding as its brief, never a resumed one.

The layer plan is the budget. A layer is sized to one fresh invocation, and the plan is what keeps the run inside its windows.

Run it against a ticket at `ready-to-build`; with no ticket there is nothing to build. The issue tracker should have been provided to you — run `/bootstrap` if `docs/agents/issue-tracker.md` is missing.

## 1. Declare the execution mode

Do this before anything else; the rest of the procedure assumes it. One writer at a time, always: a builder and the Review are never in the checkout together.

| mode | **Builder** | **Review** | when |
| --- | --- | --- | --- |
| **delegated** (default) | one fresh subagent per layer, Claude Code's `Agent` or pi's `subagent`; it hands back the whole layer — green, committed, tree clean — never per commit | the parent launches a fresh `/crucible` subagent per layer | subagents resolve |
| **in-session** | the parent builds each layer itself, with `/tdd` | the same fresh `/crucible` subagent per layer | the operator asks to watch the code being built |
| **self-review** | the parent | the parent runs `/crucible` in its own window, said plainly as weaker than a fresh seat | subagents are down |

The parent owns the contract, the plan, the routing, the records, and the push. A **Builder** — subagent or parent — never pushes: it ends at a clean tree with its commits in hand, and the parent pushes before the Review runs.

In-session mode is entered on the operator's word at invocation. A parent that fills its window mid-layer hands back at the same boundary as any builder: commit what is green, record it, and resume in a fresh session from the fit, plan and layer records.

**Done when** you can name the mode this run is in and who occupies each seat.

## 2. Fetch the contract and claim the ticket

Fetch the ticket through the tracker adapter and read the **body**: what to build, the scenario table, the acceptance criteria with their **classes**, the interfaces it owns and consumes, the flow, the decisions that bind it, what is decided against, and the blocking edges.

Read the classes closely: the ticket declared behaviour, claim, test or shape for every criterion at the cut, and the fit will witness each one. A ticket whose criteria carry no class is not yet the contract this run reads — an `/align` pass settles it rather than this run assigning classes.

**Claim it**: `gh issue edit <n> --add-assignee @me` is the run's first write, so the frontier stops offering it.

**Done when** every criterion carries its class and traces to a scenario, and the ticket is claimed.

## 3. Fit the repo

The run owns one worktree for the whole ticket — created before the fit, with the git and stack flows in [STACK.md](./STACK.md) — so the primary checkout is never the build's scratch space and the proven loop survives every layer's branch switch.

Derive the repo's own mechanics from the repo on every run, never from a cache — a cache applies yesterday's mechanics to today's repo. Read what it documents: `CONTEXT.md` and `CLAUDE.md`, CI configuration, the scripts in `package.json` / `Makefile` / `justfile`, lockfiles, `.env.example`, and the tests that already exist. One pass over those sources: what is not there is *unavailable*, named as needed rather than hunted for.

| field | what it holds |
| --- | --- |
| **commands** | the loop's commands — typecheck, focused tests, the suite — plus one command per acceptance criterion, paired with its **witness**, the test or observable that will show it |
| **secrets** | the paths a secret lives at, never a value |
| **proven** | the commit and the tooling hash the commands were run against |

Then **prove them**: run the commands at the base commit. One of three honest outcomes comes back:

- **Absent** — no suite, no typecheck, no CI. Absence is a recorded **fact** and the run proceeds: the operator's own run at hand-back is the verification such a repo has left.
- **Unavailable** — a command, a service or a secret the loop needs is missing. **Stop before writing anything**, name what is needed and the path it lives at (never the value), and escalate to the operator. Nothing is re-derived: once it is supplied, the run resumes at this step.
- **Green** — record the baseline and the suite's duration; both are what the layer's `facts` will be measured against.

Record the fit on the ticket, one comment for this run:

```markdown
### Fit — <run>, at `<commit>`

**Loop**  typecheck `<cmd>` · focused `<cmd>` · suite `<cmd>` · CI `<run | absent>`
**Proven**  `<commit>` at tooling `<hash>` — green · absent · unavailable
**Secrets**  `<path>` (paths, never values)

| criterion | class | witness | command |
| --- | --- | --- | --- |
| <the criterion, short> | behaviour | <the test or observable> | <what runs it> |
```

The tooling hash is over the repo's declared tooling as it stood — lockfiles and tool config, hashed with the shell's own tool — so a claim proven against stale mechanics is visible.

**Done when** every criterion has a witness and a command, the commands have been run, and the fit is on the ticket.

## 4. Cut the layers

Cut by **code dependency**: the schema, the shared types, then their consumers. A layer is green but not independently valuable — that is the point of the cut, and the reason it is a branch rather than a ticket. The first layer sits on the ticket's base — the trunk, or the alignment's docs branch where the contract put a document on one — and each layer sits on the one below it.

Assign every acceptance criterion to exactly **one owning layer**, and name the layers that **contribute** to it: the owner is the layer whose diff makes the criterion hold, and the contributors are the layers it needs to exist first. The owner is what the pull request's body will carry later.

Size is the budget: a layer fits one fresh invocation. Too big is a layer whose brief a fresh builder cannot hold; too small is a layer that only makes sense as part of another. A ticket that cannot be cut into fitting layers is not this run's to shrink — take it back for an `/align` pass.

Record the plan on the ticket, one comment for this run, so a re-entered run resumes rather than planning again:

```markdown
### Plan — <n> layers

| # | branch | base | owns | contributes |
| --- | --- | --- | --- | --- |
| 1 | `feat/…` | `main` | criteria 1, 2 | 3 |
| 2 | `feat/…` | `feat/…` | criterion 3 | — |
```

**Done when** every criterion has exactly one owning layer, every layer names its base, and the plan is on the ticket.

## 5. Invoke a Builder per layer

Prepare the branch first — created off its base, bottom to top, in the run's worktree, with the flows in [STACK.md](./STACK.md). In **delegated** mode the parent hands the brief below to a fresh subagent; in **in-session** mode the brief is the parent's own working constraint. Either way the brief goes to the builder, never onto the ticket.

One fresh invocation per layer, with the brief. The brief carries the contract by reference and the layer's material verbatim — never a restatement of the contract:

```text
<builder-brief>

Layer: <branch> off <base> · Ticket: #<n> · Plan: <the plan comment>

You build one layer of this ticket. Read the contract on the ticket; the criteria below are yours, verbatim.

Owns: <criterion 1>, <criterion 2>
Contributes to: <criterion…> (owned by <layer>)
Consumes: <the settled interfaces this layer calls, from the contract>
The loop: <typecheck>, <focused tests>, <suite> — proven green at <commit>.
Secrets live at: <paths> — never a value. If one is unreadable, stop and say so.

TDD the layer: /tdd, one /commit per red → green → refactor cycle — the refactor included, never
skipped. Commit on a real green, not on your say-so.

Change only what the layer's criteria need. Leave the tree clean. Do not push, do not open anything,
do not vet your own work: the parent owns the stack and the Review.

If the window fills before the layer is done: commit what is green, leave the tree clean, and hand
back a brief naming what is done and what remains. A split layer beats a degraded one.

Hand back: the commits, the facts you proved (typecheck, focused tests, suite), and confirmation
the tree is clean.

</builder-brief>
```

A builder ends when it judges the layer done — green, committed, tree clean. A hand-back that is anything else is a brief that failed its completion criterion, and the parent re-briefs rather than resuming the builder. The parent pushes the layer next (§6), then launches the Review (§7).

A builder that stops because the window filled hands back at a green commit. Push what exists, record it, and cut the remainder into a new layer above it: the plan changed, so the split layer gets its own brief like any other.

**Done when** the layer's commits are in and the tree is clean.

## 6. Push the layer

`gh stack push` once the tree is clean — a branch per layer, no pull request. The commands, the branch naming and the stack's construction are in [STACK.md](./STACK.md). A push is idempotent: re-running it with the branch already up changes nothing.

**Done when** the layer's branch is on the remote, with no pull request against it.

## 7. Review the layer

Launch `/crucible` as a fresh subagent — in **delegated** and **in-session** mode — with the layer's delta `<base>...<branch>` and the ticket's contract: it executes in its own context, against the run's worktree, never in the parent's window. In **self-review** mode the parent runs it itself, said plainly as weaker. It returns **Findings**; it never posts. Falsification is the gate: every criterion the layer owns has its witness mutated — one hand-placed mutation each, red required — a survived mutation is not accepted, and the consumers of every changed surface are grepped.

A layer is vetted here on its own delta. The one whole-stack pass runs after the last layer, in the shipping half.

**Done when** every owned criterion has a falsification result, and the findings are in hand.

## 8. Route the findings

| finding | route |
| --- | --- |
| **behaviour · claim · test** | returned to a **fresh invocation** with the finding as its brief; the fix lands wherever the finding lives |
| **shape** | rides at P2 — recorded in the layer record, never a fix round, never a stop |
| **a scenario the contract never named** | a **contract change**: an `/align` pass on the ticket, not a fix round |
| **matching an out-of-scope entry** | **suppressed**, citing the entry — never work |
| **a product call the review cannot decide** | asked in session; the answer is recorded as a decision row or an out-of-scope entry |

A fix round is a new Builder invocation — in **delegated** mode a fresh subagent, in **in-session** mode the parent — with the findings as its brief, never a resumed builder:

```text
<fix-brief>

Layer: <branch> · Ticket: #<n> · Round: <n> of 2

The **Review** returned findings against this layer. Each is a question with its evidence; answer it in
the code — the fix lands wherever the finding lives, which may be outside this layer's diff.

<the findings verbatim: class, severity, found at, question, evidence>

Same boundary as the layer brief: /tdd where a test is the answer, one commit per cycle, tree clean,
no push. Do not widen scope: a finding that adds a scenario is not yours to fix — say so and stop.

</fix-brief>
```

The layer gets **two rounds at most**; a finding still open after its second is escalated in session with what was tried and what remains, and the operator decides. A round that commits is re-pushed (§6) before it is re-vetted, and crucible re-runs on the criterion the round touched — not on the whole layer: a round that does not turn that mutation red did not close the finding, and a round that widens scope is a contract change wearing a fix's clothes.

**Done when** every acting finding is closed by a red mutation or escalated with what was tried, and every non-acting finding is recorded as it resolved.

## 9. Record the layer

Post one layer record on the ticket — the template below and nothing beyond it; it is the parent's durable memory, which is what a re-entered run reads instead of re-deriving:

```markdown
### Layer — `<branch>` off `<base>`

**Owns** <criteria> · **Contributes to** <criteria> · **Window** peak <n>
**Commits** `<sha>` <subject> · …
**Facts** typecheck green · focused green · suite green · <n> tests
**Falsification** <criterion> → red · <criterion> → survives (test P1, resolved round 1)
**Findings** behaviour P1 ×0 · claim P1 ×1 (resolved) · test P1 ×1 (resolved) · shape P2 ×2 (riding) · suppressed ×1
```

Findings are counted here and nowhere else: they are ephemeral in the loop, and never transcribed into a pull request. The peak window is measured, not capped — the layer plan is the enforcement, and the measurement is how the next plan gets better.

**Done when** the layer record is on the ticket and the next layer's base is this layer's branch.

## 10. Hand back

When every layer is built, vetted and pushed:

- the stack's branches, bottom first, with what each owns;
- the fit's commands, one per criterion, for the operator to run and see the ticket work;
- nothing submitted: the drafts, their bodies and the flip come after the operator has seen the criteria work.

No pull request was created at any point. A run re-entered against the same ticket reads the ticket's fit, plan and layer records and its own stack, and resumes at the first layer without a record — the resume flow is in [STACK.md](./STACK.md).

**Done when** the stack and the fit's commands are in the operator's hands, and nothing is submitted.

## Where this goes next

The shipping half of the stage: the stack submitted once as drafts, each body written from the contract, the criteria distributed one owning layer each, ticked by the operator, and the flip once every tick is in.

## Related

- `/crucible` — the **Review** every layer passes through.
- `/tdd` — the cycles inside a layer.
- `/commit` — one per cycle.
- `/align` — where a finding that names a scenario goes, and where a ticket that cannot be layered goes.
- `/cut` — the stage before this one.
