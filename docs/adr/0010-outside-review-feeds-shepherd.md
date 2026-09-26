---
status: accepted
---

# Outside review feeds `/shepherd`; crucible stays the only gate

Amends [ADR-0009](./0009-the-build-is-a-sequential-fresh-child-loop.md): crucible remains the only review
policy, and the pull request gains a stage after it. Aligned in #108.

## Context

A full build day ended every run at an open pull request with nothing watching it. The operator relayed
the review bot's findings by hand, typed each re-review trigger, and asked colleagues for review — about
half of their build-phase turns. The long idle gaps were all waits after a pull request opened. Most of
the bot's findings needed only a reply; the few that needed code were input cases crucible's walk never
reached. A 5/5 from the bot was later shown wrong by a colleague, so the score is a signal, not proof.

## Decision

**`/shepherd` owns the pull request from open to ready to merge.** `/build`'s last act starts it on the
pull request it opened; the operator can start it on any other. It waits for the review bot's round to
finish, triages each thread, and acts:

- a finding inside the contract is fixed through a fresh unit and crucible, never a parent edit;
- a finding the contract already decides is answered with the evidence, and resolved;
- a finding that changes the contract is a decision **Escalation**;
- a colleague's comment gets a drafted reply, posted only on the operator's yes.

It stops at 5/5 with every thread fixed or answered, escalates when stuck below it, and gives up after
five re-reviews. At 5/5 it asks before requesting colleague review. It never merges.

**Outside review is input, not a gate.** The bot's findings and colleagues' comments enter the loop as
threads to triage; the gate each fix passes is crucible, as ADR-0009 set. The score is recorded, not
chased past the operator's call.

## Considered options

- **A §5.1 loop inside `/build` until 5/5** — rejected: unbounded, against build's two-round cap, and any
  open style point caps the score, so it would chase style as if it were behaviour.
- **Wrapping Greptile's greploop** — rejected: it fixes in its own session and replies to everyone. Its
  two ideas are kept: never trigger while a review runs, and stop only at 5/5 with no open threads.
- **Auto-merge alone** — rejected: it removes the last click, not the relay before it; and the
  **Operator** merges.

## Consequences

- `CONTEXT.md` gains **Shepherd** and **Escalation**; **Operator** keeps the merge.
- Each finding that needed code is tagged alignment, crucible or style, so the measure says which stage
  should have caught it.
- The notifier that carries escalations off the session is its own work, in the dotfiles repo.
