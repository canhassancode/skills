---
status: accepted
---

# `/specifier` is the sole author of acceptance criteria

Supersedes [ADR-0003](./0003-lane-owns-gauntlet-fitness.md).

## Context

ADR-0003 split gauntlet-fitness in two: `ticket-lint` at Preflight owned the guarantee, and the ticketing lane owned *shaping* — `/to-tickets`, `/to-spec` and `/grill-with-docs` wrote each acceptance criterion against a seam the running system serves, so a ticket would be fit by construction.

The gauntlet rebuild (canhassancode/dotfiles#67) removed the premise under both halves.

- **`ticket-lint` no longer exists.** The rebuilt spine replaces it with an `admit` guard that validates a **Specification** against a test report — schema plus witness verification — not a ticket against a regex. The deterministic backstop the whole ADR is built around has no successor on the ticket.
- **The routing line is actively wrong.** *"A ticket with no behavioural criterion is class-A unfit → `/implement`"* misroutes roughly three quarters of pull-request review feedback (Beller MSR 2014; Mäntylä TSE 2009), which the rebuild admits deliberately through a green-before-and-after `invariant` criterion class. Routing now asks *can you name an existing, passing test this could plausibly break* — a question about the repo, not about the ticket.
- **Class-B unfitness dissolves.** *"A real outcome reachable at no Edge"* was a run-time escalation precisely because `ticket.json` could not see the repo's served seams. `/specifier` can: it runs with the server up and a report in hand.

The shaping half was always the weak half, and ADR-0003 concedes it — the stampers cannot gate, only advise, in prose, with no running system, no test report and no witness.

## Decision

**`/specifier` is the sole author of acceptance criteria, and the ticketing lane authors none.**

- **`/specifier`** derives the run contract from a fresh pull, **executes it green in front of the operator**, binds every criterion to a test in the report that run produced, and publishes the specification to the ticket. Publication is approval, and the gate is structural: preflight only ever fetches from the tracker, so an unapproved specification has no address.
- **A ticket keeps a plain-prose definition of done.** The Given/When/Then template is removed from `/to-tickets`, the served-Edge clause from `/to-spec`, and the build-bound shaping section from `/grill-with-docs`. A ticket that carries criteria creates two authorities on "done", and the weaker, older one is the one visible in the backlog.
- **The gauntlet vocabulary leaves this repo.** `Edge`, `Gauntlet-fitness`, `Unfitness class`, `Grow-the-seam prep ticket`, `Ticket-lint` and `Stamper` are removed from `CONTEXT.md`; `Specification` replaces them. No skill here knows the gauntlet exists except `/specifier`, which produces its input, and `/gauntlet`, which invokes it.

## Considered options

- **Keep the shaping, drop only `ticket-lint`** — rejected. Shaping with no running system produces criteria that *look* runnable, so they get trusted. That is worse than redundant once a skill downstream authors real ones against a real report.
- **Keep the Given/When/Then template as a courtesy to `/specifier`** — rejected. It is the visible authority on "done" in the backlog and it is the older one; `/specifier`'s concreteness rule re-derives what it needs from prose anyway.
- **Delete ADR-0003** — rejected. It is an accepted ADR, so the reversal needs its own record rather than a bare revert.

## Consequences

- **Onboarding a new repo is `git pull`, `/specifier`.** `.gauntlet/config.json` is deleted; every key it held is derived in-session and frozen into the specification, having been proven.
- **Non-behavioural work stops being refused work.** It routes to `/implement` when it can break no existing test, and to the gauntlet as an `invariant` when it can.
- **Staleness shrinks from months to hours** — a config nobody notices is wrong becomes a specification authored the day it runs, failing loudly with *command not found*.
- **`/specifier` is a new coupling to the gauntlet**, deliberately concentrated in one skill instead of spread across three. The three that carried it are now gauntlet-agnostic and work in a repo that has never seen it.
- Reversible: the removed shaping is one commit's worth of prose, recorded here and in `CONTEXT.md`'s flagged ambiguities.
