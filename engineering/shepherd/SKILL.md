---
name: shepherd
description: Take one open pull request through the review bot's rounds until every thread is settled or a decision is owed — triage each thread, fix through crucible, reply with evidence, and ask before colleague review.
argument-hint: <pr-ref>
---

# Shepherd

The stage after **Build**. `/shepherd <pr-ref>` owns one pull request from open to ready to merge: it
waits for the review bot's round to finish, triages every outside comment as a thread, and acts — fixed
through a fresh builder and crucible, answered with evidence, put to the operator when a colleague wrote it,
or escalated when it changes the spec. It never merges.

**Outside review is input, never a second gate.** The bot's findings and colleagues' comments enter as
threads to triage; crucible stays the only gate each fix passes, and the score the bot carries is a
signal, not proof — a colleague has already shown it wrong.

The operator starts it in a fresh session — on the pull request `/build` hands back, or on any other.

## What the run carries

| input | what it is | who resolves it |
| --- | --- | --- |
| **the spec** | the linked ticket's body — goal, behaviour lines, out of scope, decisions — and its locked tests | the pull request's ticket |
| **the round** | the review bot's pass over the pull request, ended by §2's done signal | the review bot |
| **crucible's notes** | an input case judged safe, with the line that makes it safe — what a reply quotes in §5 | crucible's vetting |

Two shapes belong to this skill, and everywhere it writes them they take the same form:

- **escalation** — `decision | action | information`, one line, one link. The level says how soon the
  operator needs to look: **decision** for a choice only they can make, **action** for a yes before
  something outward happens, **information** when nothing is asked. The session is its sink.
- **finding tag** — `alignment | crucible | style`, one per finding that needed code, recorded in this
  run's one comment on the ticket. It splits the measure by the stage that should have caught the finding.

## Procedure

### 1. Open the watch

Resolve the pull request and read the spec it closes — never the pull request's own summary. One pull
request, one spec: a change to what it promises is §7's escalation, never a
quiet rewrite here.

```sh
gh pr view <n> --repo <owner>/<repo> --json number,title,body,url,reviewDecision
```

**Done when** the pull request, its spec and the repository's code-owner rule are in hand.

### 2. Wait for the round

A round is open while the review bot is working: its 👀 means reviewing, and its 👍 on the pull request
description (the first review) or on the trigger comment this run wrote (each re-review) means done. Ask
for the next round only once the one before it has closed — never while a round runs, or the bot reports
on a moving diff.

After the done signal, read the summary comment and every thread, then triage (§3). No done signal within
15 minutes sends an **information** escalation — one line saying the round has not closed.

**Done when** the round is closed, and its summary and threads have been read.

### 3. Triage each thread

Nothing is fixed or answered until the summary and every thread have been read, and each thread takes
exactly one route:

| the thread | the route |
| --- | --- |
| a finding inside the spec | a fix through a fresh builder and crucible — §4 |
| a finding on a behaviour line that has had its fix round | a rule question, no fix — §4 |
| a finding the spec already decides | an answer with the evidence — §5 |
| a colleague's comment | a reply put to the operator — §6 |
| a finding that changes the spec or a locked test | a decision escalation — §7 |

Read the `## Fix rounds` table and name each finding's behaviour line (§4) before routing it: a finding on
a line that has had its round takes the rule question whichever other row it fits.

**Done when** every thread in the round carries one route.

### 4. Fix inside the spec

A fix is a fresh builder carrying the finding in `/build`'s fix brief
([briefs.md](../build/references/briefs.md#fix)), then `/crucible` over the fix's commits in a subagent of
its own — never a parent edit in this session, and never the review bot's word as the gate. Locked files
stay read-only; one commit, the lock check and the full suite green, and the re-review is asked for in a
trigger comment only after the vetting is green. A fix that changes what a `## Verify` step exercises
re-runs that step through `/build`'s verifier brief and replaces its evidence in the pull request body
with the new commit's; a step it can't run is unticked and put to the operator. Every fix ends by writing
the body's Summary and Decided limits again from the diff as it now stands, and crucible reads the body
against the diff: a body that still describes an earlier round is what colleagues send back most.

Each finding that needed code is tagged `alignment | crucible | style` — which stage should have caught
it — and recorded in this run's one comment on the ticket.

Each behaviour line gets one fix round across build and shepherd — `/build`'s rule
([SKILL.md](../build/SKILL.md), step 5), counted in the pull request's `## Fix rounds` table, which you read
before any fix. Name each finding's `line` and `caused by` as crucible does
([SKILL.md](../crucible/SKILL.md#return)): the behaviour line it threatens, quoted from the spec, and the
`fix:` commit whose hunk its `file:line` sits in or depends on, found with `git log -L` or `git blame`. A
finding counts against its `caused by` fix's line; with no `caused by`, or one from a `none` round, it counts
against its own `line`. A line with no round yet gets one: write its row `| <line> | <sha> (shepherd) | — |`
once the fix commits.

A finding on a line that already has a round, whether build's or shepherd's, stops that line: no builder,
no fix. Write the date and the finding in its Stopped cell, then put one rule question to the operator as
a decision escalation: the finding, every survivor crucible raised on that line, and a single sentence
that quotes the stopped line word for word and ends in a question mark. The question goes in this
session's last message, answered or not. A ruling that leaves every behaviour line's wording unchanged is
added to the ticket's `## Decisions` and the run carries on with it as spec; one that rewrites a line is
§7's escalation, to `/align`.

A finding with `line none` gets one fix round of its own, logged as `| none | <sha> (shepherd) | — |`.
Still open after it, it goes to the operator as an information escalation and stops nothing.

**Done when** the fix is committed, crucible has vetted it, its tag is recorded and its Fix rounds row is written — or the line is stopped and its rule question asked.

### 5. Answer with evidence

A finding the spec already decides is answered, not fixed: reply on the bot's thread with the
evidence — crucible's note and the line that makes the case safe, the Decisions entry, or the Out of
scope line — and resolve the thread.

```sh
gh api repos/<owner>/<repo>/pulls/<n>/comments/<id>/replies -f body="<the evidence>"
```

**Done when** the reply is on the thread with its evidence, and the thread is resolved.

### 6. A colleague comments

A colleague's comment is a thread like any other, but its reply goes out only on the operator's yes:
draft the reply, put it and its evidence to the operator as an action escalation, and post after the yes.

A colleague's finding that needs code takes the same §4 route; the reply that follows still waits for the
yes.

**Done when** the reply carries the operator's yes, or the thread waits with the question outstanding.

### 7. Escalate a spec change

A finding that changes what the spec promises — a behaviour it never named, a locked test that looks wrong, a decision it settled the
other way, scope it excludes — is neither fixed nor answered here. It goes to the operator as a decision
escalation, one line and one link, and the run keeps to the threads it can still close while that answer
is owed.

**Done when** the escalation is in session and no fix has touched the spec or a locked file.

### 8. The stop rule

The run is done when a round closes with every thread fixed or answered, whatever the score. The operator is then asked before any colleague review request — one action escalation that gives the score as it stands. Nothing is requested until they answer, and a repository that requests code owners when a pull request goes ready does so on its own; asking for anyone else waits on the operator.

No re-review is asked for to lift a score when no thread is open: the bot gives its top score to pull requests colleagues go on to block, so the score proves nothing a settled thread doesn't. Two re-reviews are the cap; threads still open after them go to the operator as a decision escalation and the run stops.

The finished pull request is the operator's to merge; this run never merges it.

**Done when** the run has asked, or has escalated and stopped.

## Boundaries

**Always** — read the spec before every fix · fix through a fresh builder and crucible · reply to the review bot with evidence · keep each fix inside the spec.
**Ask first** — any reply to a colleague · requesting colleague review.
**Never** — merge · give a behaviour line a second fix round without a ruling · post to a colleague without a yes · a fix without a fresh builder and crucible · edit a locked file.

## Related

- `/build` — the stage before this one; its hand-back names the pull request to start this run on.
- `/crucible` — the only gate each fix passes.
- `/align` — where a spec change goes once the operator has answered the escalation.
