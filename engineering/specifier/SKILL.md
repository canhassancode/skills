---
name: specifier
description: Turn a ticket or a pull-request review comment into the specification the gauntlet runs against — derive the run contract from a fresh pull, prove it green in a throwaway worktree, and publish it to the ticket.
argument-hint: <ticket-ref | review-comment-url>
disable-model-invocation: true
---

# Specifier

The gauntlet's only entrance and its only human gate. It interrogates the **ticket** — is this a fit? — and the **repo** — what are the commands, and do they run? — then publishes the **specification** the machine consumes.

It is a session, not a form. Iterate as freely as you like; the single gate is the moment it publishes. **Publication is approval**, and the gate is structural rather than promised: preflight only ever fetches from the tracker, so an unapproved specification has no address and the gauntlet cannot reach it.

Run it on the default branch, clean tree, freshly pulled. The specification's whole worth is that it was proven against what the gauntlet will clone — which is a worktree, not the clone you are sitting in, so the proof runs in one too.

The issue tracker vocabulary should have been provided to you — run `/bootstrap` if not. The artefact's schema, id rule and publication format live in [SPECIFICATION.md](./SPECIFICATION.md).

## Procedure

### 1. Resolve the origin

Two kinds, and there is no third — a conversation is where deliberation happens, not an origin.

| argument | `kind` | `ref` | `thread` |
| --- | --- | --- | --- |
| a ticket reference | `ticket` | the ticket number | — |
| a review comment, a `request changes`, a Greptile or CodeRabbit finding | `review-comment` | the ticket the pull request was opened from | the comment id |

`ref` is both the publication address and the prefix on every criterion id. A review comment is an event against a unit of work rather than a unit of its own, so its specification joins the stack on that ticket. Where the pull request came from no ticket, `ref` is the pull request number.

Fetch a ticket through the tracker adapter. On GitHub, fetch a review comment with `gh api repos/<owner>/<repo>/pulls/comments/<id>` and read the thread around it — the reviewer's actual point is often two comments deep.

Done when `origin` carries `tracker`, `kind`, `ref` and `url`, plus `thread` on the review-comment kind.

### 2. Assess fit

Two tests, both cheap, both spent before a proof run is.

**The routing rule.** *Can you name an existing, passing test that this change could plausibly break?* Yes → the gauntlet. No → say so and route it to `/implement`.

Non-behavioural work is not declined work. Roughly three quarters of review feedback changes no observable behaviour, and most of it still passes this rule: extract a module, bump a dependency, delete an impossible catch. What fails it is a comment typo, an `any` given a type, *"the spacing looks wrong"*.

Fitness and worth-it are different axes. This rule answers fitness alone; whether the change is worth a run is your call at the gate, and is not machined.

**The concreteness rule.** Every sentence that will become a criterion carries its values. *"Given an invalid id"* cannot become an assertion; *"given id 9, which does not exist"* can. Push for the value.

This survives a `ready-for-agent` ticket and is not a re-align: the alignment settled what behaviour should exist, and this asks whether the sentence can bind. *Agreed, but not yet concrete enough to bind* is the commonest honest decline.

### 3. Derive the contract

Every command comes from the repo in front of you — `package.json` scripts, the tree, the dev-server config. There is no `.gauntlet/config.json`; this skill is what deleted it, and onboarding a new repo is `git pull`, `/specifier`. The field set is in [SPECIFICATION.md](./SPECIFICATION.md).

`coverage` comes from the repo like the rest — the instrumented suite, and where that run writes its JSON. It is optional, and it is **a command of its own, never `acceptance.run`**, for the reason [SPECIFICATION.md](./SPECIFICATION.md) gives. Where the repo has no instrumented suite to give, leave the field out.

### 4. Declare the carriage

`git worktree add` checks out tracked files only — gitignored and untracked files do not come with it. `install` rebuilds `node_modules/` and `build` rebuilds `dist/`, but a per-repo precondition has nothing to rebuild it, so it reds the run somewhere far from the cause and reads as a harness bug.

Show the operator the main clone's ignored inventory and ask which entries are preconditions rather than build output.

```
git status --ignored --porcelain

!! dist/            ← build output, dropped
!! local.settings   ← precondition, kept
!! node_modules/    ← build output, dropped
!! secrets.d/       ← precondition, kept
```

**Declare-then-falsify, not discover-by-proof.** The operator declares and step 5 checks, because **the proof can show a path is necessary, never that the list is sufficient.** A file whose absence changes behaviour without breaking anything — a flag that silently defaults, a seed row that makes a fixture pass for the wrong reason — leaves the proof green with the list incomplete. Declaration is the operator's knowledge; the proof is the check on it.

Done when `carry` is a list of paths that exist in the clone, possibly empty. **Paths only, never contents**, for the reason [SPECIFICATION.md](./SPECIFICATION.md) gives.

### 5. Prove it, where the gauntlet will stand

Not in the clone you are sitting in: it has the ignored files, and the worktree the gauntlet runs in will not.

```bash
WT=$(mktemp -d -t specifier-<ref>-XXXX)
git worktree add --detach "$WT" HEAD
```

The throwaway lifecycle `/review` already uses. Copy the declared paths in, then run everything there — install, build, the acceptance suite, the instrumented suite, the server, every ready probe, the startup measurement.

Then falsify the list. Drop a declared path, re-run the narrowest command that should depend on it, and watch it red — that is necessity, and it is the whole check the declaration buys. Where it stays green, say so and hand the keep-or-drop back to the operator: green without a file proves nothing loud depends on it, never that the file is unneeded.

Then check the coverage report, whose failure is silent rather than red. Arriving at `coverage.output` settles only the `mkdir -p` class. What makes the guard score fiction is the report naming build output instead of source: **it must name the files under `sourcePaths`.** One keyed to `dist/` or to transpiled sources still parses and still lands where it was promised, yet yields a coverage fraction of 0.0 for every function the complexity tool found in `src/` — so every function scores its maximum CRAP and the finding is uniformly wrong rather than absent. Confirm at least one path in the report resolves under a declared source path, and report what you found.

Done when every command has exited zero, the suite has reported zero failures, every probe has answered, any declared coverage report has arrived and named source files, and every declared path has been dropped once and its result reported — in the worktree, in front of the operator. **A command that has not run green in the worktree is not frozen into a specification.** The same run produces the baseline report every binding below is copied from.

**`git worktree remove --force "$WT"` before the session ends, by whichever route it ends** — published, declined, abandoned. The tree is detached, so nothing survives it and there is no branch to clean up.

This is the step that catches the class no config file can — an unapproved transitive build script, a report directory the runner will not create, a stack the Bash allowlist has never seen. It now catches the missing-precondition class as well, at the human gate rather than at an unattended qa.

### 6. Classify, narrating as you go

State each classification and its reason **as you decide it** — *"this is an invariant because it binds to a test that passes on the baseline I just ran."* Awareness is bought by narration; a per-criterion approval would be N gates on one specification, which is the iterate-until-good shape this design rejects. One gate, at publication.

| class | untouched tree | after the examiner | after the coder |
| --- | --- | --- | --- |
| `behaviour-N` | does not exist | red | green |
| `invariant-N` | green | green | green |
| `retired-N` | green | absent | absent |

**A behaviour is witnessed, not declared.** It names the `edge.address` it asserts through and points `edge.witness` at a passing test that already drives that address. `witness: null` is legal and says out loud: this is a new seam.

**An invariant is found, never written.** It binds only to a test that already exists and passes — a test nobody authored to fit this change is the only ruler a green-only criterion can have. Where no test covers what you want to preserve, you cannot declare it an invariant. That is an honest refusal.

**A retirement asserts absence.** Say *"retire `engine.test.ts`"* and expand it from the report you just ran, grouped by file, frozen into the specification. A bare file pointer would be a standing instruction that deletes a test a colleague lands after you approved it.

Every bound name is **copied from the baseline report, never typed**. Ids follow the high-water mark in [SPECIFICATION.md](./SPECIFICATION.md).

### 7. Write the procedures

Criteria and procedures are separate lists, and **QA is never shown a criterion**. A criterion is asserted by code and settled by an exit code; a procedure is executed by a model acting as a user and judged against what a person would perceive.

Each is `{id, at, do, expect}`. `at` is the address, **given, never chosen** — a QA stage that picks where to poke reasons its way onto the implementation's own seam and proves nothing. Check every `at` answers while the server is still up; it is free.

An empty list is legal and means QA is skipped. Say that in plain words at the gate rather than letting silence carry it.

### 8. Admit it before you ask

The worktree is still standing and the report is still in it. Write the assembled specification to `.gauntlet/spec.json` there and put it through the gate that will judge it at preflight:

```bash
"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/gauntlet/run.py" admit specifier
```

`exitCode` must be `0` with an empty `problems`. Where it is not, fix what it names and run it again — an inadmissible specification is never rendered to the operator, because publication **is** approval and a gate that approves something the machine then refuses has approved nothing. This is the one check the session cannot reason its way to: `admit` verifies the schema, every binding against the baseline report, and the entry stage it derives. It costs one command against a report already in hand, and the `baseline-tests.json` it writes dies with the tree.

### 9. Render the whole thing

Nothing elided, nothing behind a link. Every choice that leads to a run belongs on one screen: where it will publish, each criterion's class, the test it binds to and whether it passes right now, the address QA will drive, the commands just executed in front of you, and what the run will carry into its worktree. Where `carry` is empty, say *nothing carried — a fresh worktree needs no preconditions* in words, and where `coverage` is absent, *no coverage declared, so crap will collect nothing* — rather than letting an absent heading carry either. On a review-comment origin the header names the thread `ship` will reply into as well as the ticket it publishes to.

```
SPECIFICATION — #42 "Order lookup returns 404 for a missing order"
Publishing to: GitHub issue #42

CONTRACT — proven green in a worktree just now
  build          pnpm type-check                          ✓ 4.1s
  acceptance     pnpm test:integration                    ✓ 38 passed, 0 failed
  coverage       pnpm test:coverage                       ✓ 14 files under src/
  serve          pnpm dev → http://127.0.0.1:4321/        ✓ ready in 6s
  source         src/

CARRIED — proven in that worktree just now
  local.settings                                 ✓ serve.ready red without it
  secrets.d/                                     kept on your word — nothing red without it

CRITERIA
  42/behaviour-1   Given no order with id 9, when GET /orders/9,
                   then the response status is 404
                   edge     GET /orders/:id
                   witness  tests/orders.spec.ts
                            "GET /orders/1 returns the order"     ✓ passing

  42/invariant-1   Given order 1 exists, when GET /orders/1,
                   then the response status is 200
                   binds    tests/orders.spec.ts
                            "GET /orders/1 returns the order"     ✓ passing

RETIRED
  src/libs/component-resolver/engine.test.ts    66 tests    ✓ all passing

PROCEDURES
  procedure-1      at      http://127.0.0.1:4321/orders/9        ✓ address responds
                   do      Open the page in a browser and read it.
                   expect  The page shows "Order not found".
                           No error banner appears.

ADMIT    exit 0 — entry stage examiner, no problems

ROUTING  gauntlet — 1 behaviour, 1 invariant, 1 retirement, 1 procedure. QA will run.

Publish this?
```

### 10. Publish, or end the session

**Publish** — append the specification to `ref` as a new comment, in the format [SPECIFICATION.md](./SPECIFICATION.md) gives. Always append: the blocks stack, the newest wins, and the history stays readable.

Where the rendered JSON exceeds the tracker's comment limit, **refuse and name the split** — a silently truncated `retired` list is a licence to delete tests nobody saw, and a specification retiring several hundred tests is several specifications.

**End without publishing** — nothing is published and nothing exists. Name the route on the way out:

| what you found | route |
| --- | --- |
| fails the routing rule | `/implement` — labels untouched, the work still happens |
| agreed, but not concrete enough to bind | remove `ready-for-agent` and re-grill |
| genuinely not worth doing | `wontfix` |

On a review-comment origin your reply in the thread is the record — a resolved thread is collapsed, not deleted. There is no refusal artefact and no `not-gauntlet-fit` label: the next session re-derives that assessment for free from a contract it must prove anyway. `ready-for-agent` and gauntlet-fit are different claims, so a decline is not evidence the triage was wrong.

## Related

`gauntlet` - dynamic workflow (claude code) runs the specification that's published `to-tickets` — writes the ticket this reads, and never writes criteria · `implement` — where work that fails the routing rule goes
