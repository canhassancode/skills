---
name: shepherd
description: Take one open pull request through the review bot's rounds to the top score or a decision — triage each thread, fix through crucible, reply with evidence, and ask before colleague review.
argument-hint: <pr-ref>
disable-model-invocation: true
---

# Shepherd

The stage after **Build**. `/shepherd <pr-ref>` owns one pull request from open to ready to merge: it
waits for the review bot's round to finish, triages every outside comment as a thread, and acts — fixed
through a fresh unit and crucible, answered with evidence, put to the operator when a colleague wrote it,
or escalated when it changes the contract. It never merges.

**Outside review is input, never a second gate.** The bot's findings and colleagues' comments enter as
threads to triage; crucible stays the only gate each fix passes, and the score the bot carries is a
signal, not proof — a colleague has already shown it wrong.

`/build`'s last act starts this run on the pull request it opened; the operator can start it on any other
by hand.

## What the run carries

| input | what it is | who resolves it |
| --- | --- | --- |
| **the contract** | the linked ticket's body — scenarios, criteria, decisions, boundaries | the pull request's ticket |
| **the round** | the review bot's pass over the pull request, ended by §2's done signal | the review bot |
| **the crucible note** | an input case judged safe, with its evidence — what a reply quotes in §5 | the fresh unit's vetting |

Two shapes belong to this skill, and everywhere it writes them they take the same form:

- **escalation** — `decision | action | information`, one line, one link. The level says how soon the
  operator needs to look: **decision** for a choice only they can make, **action** for a yes before
  something outward happens, **information** when nothing is asked. The session is its sink.
- **finding tag** — `alignment | crucible | style`, one per finding that needed code, recorded in this
  run's one comment on the ticket. It splits the measure by the stage that should have caught the finding.

## Procedure

### 1. Open the watch

Resolve the pull request and read the contract it closes — the ticket's body, never the pull request's
own summary. One pull request, one contract: a change to what it promises is §7's escalation, never a
quiet rewrite here.

```sh
gh pr view <n> --repo <owner>/<repo> --json number,title,body,url,reviewDecision
```

**Done when** the pull request, its contract and the repository's code-owner rule are in hand.

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
| a finding inside the contract | a fix through a fresh unit and crucible — §4 |
| a finding the contract already decides | an answer with the evidence — §5 |
| a colleague's comment | a reply put to the operator — §6 |
| a finding that changes the contract | a decision escalation — §7 |

**Done when** every thread in the round carries one route.

### 4. Fix inside the contract

A fix is a fresh **Builder** invocation carrying the finding as its brief, then `/crucible` in a child of
its own — never a parent edit in this session, and never the review bot's word as the gate. The loop is
`/build`'s: `/tdd` the fix, one commit, crucible vets the criterion it names, and the re-review is asked
for in a trigger comment only after the vetting is green.

Each finding that needed code is tagged `alignment | crucible | style` — which stage should have caught
it — and recorded in this run's one comment on the ticket.

A finding gets two fix rounds at most. One still open after its second goes to the operator as a decision
escalation: the finding, what was tried, and the route it would take.

**Done when** the fix is committed, crucible has vetted it, and its tag is recorded.

### 5. Answer with evidence

A finding the contract already decides is answered, not fixed: reply on the bot's thread with the
evidence — the crucible note's safe input case and its proof, the decision row, or the out-of-scope
entry — and resolve the thread.

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

### 7. Escalate a contract change

A finding that changes what the contract promises — a scenario it never named, a decision it settled the
other way, scope it excludes — is neither fixed nor answered here. It goes to the operator as a decision
escalation, one line and one link, and the run keeps to the threads it can still close while that answer
is owed.

**Done when** the escalation is in session and no fix has touched the contract.

### 8. The stop rule

At **5/5** with every thread fixed or answered, the operator is asked before any colleague review request — one action escalation. Nothing is requested until they answer, and a repository that requests code owners when a pull request goes ready does so on its own; asking for anyone else waits on the operator.

Short of the top score with nothing left to fix, or five re-reviews run — the cap — the run sends a
decision escalation naming which of the two it is and stops. A score that reaches the top while a thread
is still open does not close the run, and stopping below it is the operator's call.

The finished pull request is the operator's to merge; this run never merges it.

**Done when** the run has asked, or has escalated and stopped.

## Boundaries

**Always** — read the contract before every fix · fix through a fresh unit and crucible · reply to the review bot with evidence · keep each fix inside the contract.
**Ask first** — any reply to a colleague · requesting colleague review · stopping below the top score.
**Never** — merge · post to a colleague without a yes · a fix without a fresh unit and crucible.

## Related

- `/build` — the stage before this one; its last act starts this run on the pull request it opened.
- `/crucible` — the only gate each fix passes.
- `/tdd` — the cycles inside a fix.
- `/align` — where a contract change goes once the operator has answered the escalation.
