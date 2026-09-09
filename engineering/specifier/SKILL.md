---
name: specifier
description: Turn a ticket or a pull-request review comment into the specification the gauntlet runs against — derive the run contract from a fresh pull, prove it green, and publish it to the ticket.
argument-hint: <ticket-ref | review-comment-url>
disable-model-invocation: true
---

# Specifier

The gauntlet's only entrance and its only human gate. It interrogates the **ticket** — is this a fit? — and the **repo** — what are the commands, and do they run? — then publishes the **specification** the machine consumes.

It is a session, not a form. Iterate as freely as you like; the single gate is the moment it publishes. **Publication is approval**, and the gate is structural rather than promised: preflight only ever fetches from the tracker, so an unapproved specification has no address and the gauntlet cannot reach it.

Run it on the default branch, clean tree, freshly pulled. The specification's whole worth is that it was proven against what the gauntlet will clone.

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

This survives a `ready-for-agent` ticket and is not a re-grill: the grilling settled what behaviour should exist, and this asks whether the sentence can bind. *Agreed, but not yet concrete enough to bind* is the commonest honest decline.

### 3. Derive the contract

Every command comes from the repo in front of you — `package.json` scripts, the tree, the dev-server config. There is no `.gauntlet/config.json`; this skill is what deleted it, and onboarding a new repo is `git pull`, `/specifier`. The field set is in [SPECIFICATION.md](./SPECIFICATION.md).

### 4. Prove it

Run what you derived: build, the acceptance suite, start the server, hit every ready probe, and measure how long the server took to answer.

Done when every command has exited zero, the suite has reported zero failures, and every probe has answered — in front of the operator. **A command that has not run green is not frozen into a specification.**

This is the step that catches the class no config file can: a per-repo precondition that reds a detached run and reads as a harness bug — an unapproved transitive build script, a report directory the runner will not create, a stack the Bash allowlist has never seen. The same run produces the baseline report every binding below is copied from.

### 5. Classify, narrating as you go

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

### 6. Write the procedures

Criteria and procedures are separate lists, and **QA is never shown a criterion**. A criterion is asserted by code and settled by an exit code; a procedure is executed by a model acting as a user and judged against what a person would perceive.

Each is `{id, at, do, expect}`. `at` is the address, **given, never chosen** — a QA stage that picks where to poke reasons its way onto the implementation's own seam and proves nothing. Check every `at` answers while the server is still up; it is free.

An empty list is legal and means QA is skipped. Say that in plain words at the gate rather than letting silence carry it.

### 7. Render the whole thing

Nothing elided, nothing behind a link. Every choice that leads to a run belongs on one screen: where it will publish, each criterion's class, the test it binds to and whether it passes right now, the address QA will drive, and the commands just executed in front of you. On a review-comment origin the header names the thread `ship` will reply into as well as the ticket it publishes to.

```
SPECIFICATION — #42 "Order lookup returns 404 for a missing order"
Publishing to: GitHub issue #42

CONTRACT — proven green just now
  build          pnpm type-check                          ✓ 4.1s
  acceptance     pnpm test:integration                    ✓ 38 passed, 0 failed
  serve          pnpm dev → http://127.0.0.1:4321/        ✓ ready in 6s
  source         src/

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

ROUTING  gauntlet — 1 behaviour, 1 invariant, 1 retirement, 1 procedure. QA will run.

Publish this?
```

### 8. Publish, or end the session

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

`gauntlet` — runs the specification this publishes · `to-tickets` — writes the ticket this reads, and never writes criteria · `implement` — where work that fails the routing rule goes
