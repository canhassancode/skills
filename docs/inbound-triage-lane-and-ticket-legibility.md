---
created: 2026-07-26
updated: 2026-07-26
sources: wayfinder grill session (2026-07-26), ticket #7 on map #4
---

# Inbound Triage Lane & Ticket Legibility (grill)

Whether the inbound/triage lane survives in Hassan's workflow, and what the agent brief has to look like for a **human** to read it first. A `grill`-sourced decision, resolving ticket #7 off the skills/second-brain wayfinder map (#4 on `canhassancode/dotfiles`).

## The question

With `ready-for-human` and `pickup` provisionally retired while charting, does the inbound lane — `triage`, the five state roles, the agent brief — survive at all? Wayfinder had eaten the front of the SDLC, and the triage labels totalled 4 instances across personal repos against 50 wayfinder tickets.

## Decisions

1. **The lane survives whole — one skill, two trackers.** It was never dead; it was measured on the wrong surface. `/triage` already resolves its tracker through an adapter (see [Dual-Track Tracker Adapter](./dual-track-tracker-adapter.md)), so splitting it into work-triage and personal-triage would duplicate ~1,500 words to encode a difference that is about *inbound volume*, not method.
2. **`ready-for-human` is un-retired.** The retirement argued that when you are the only human, every ticket is ready-for-human by default, so the label partitions nothing. That misreads what it partitions: not humans from other humans, but **what an agent can be trusted to finish alone from what it cannot**. Solo work sharpens that distinction rather than collapsing it.
3. **`pickup` is deprecated anyway** — but for a different reason: 574 words of per-ticket ceremony guarding a drift risk that `/implement` absorbs. Its blast radius is 8 references across 6 files, two of them load-bearing (the agent-brief `Key interfaces` field and the stricter-for-agents rule are both *justified by* pickup, so they need rewording rather than deleting).
4. **No gate line added to `/implement`.** The discipline moves to the human at invocation time. `/implement` does gain `disable-model-invocation: true`, matching upstream and 22 of 40 local skills — every other skill that mutates something consequential already has it.
5. **The agent brief gains two mandatory plain-English fields**, on *both* states: **Why this matters** (the observable stake) and **Why this routing** (why it is yours, or why it is safe to delegate). Two rather than one because they have different lifetimes — the stake survives re-scoping; the routing flips as blockers clear.
6. **Personal repos are dormant, not deleted.** Two triggers wake the lane: inbound work you did not write, or a stale queue. `/triage` itself is left unchanged until the manual sweep grates.

## Sharpest insight

**A dead-looking lane is often a measurement artefact.** The evidence for retirement counted GitHub labels only. Journals for June–July show the triage vocabulary used **69 times across 8 separate days in July** — `ready-for-agent` 24, `ready-for-human` 21, `needs-triage` 10 — all of it on the work Linear. Meanwhile the one personal repo that "showed life" (10 `ready-for-agent` on brushfeed) turned out to be a single `/to-tickets` batch dumped on 3 May, none assigned, none closed, untouched for twelve weeks. The lane's habitat is the work tracker; the personal-repo signal was one stale batch pointing the wrong way.

The second insight: **`ready-for-human` is a delegability predicate, and its four causes fail very differently when handed to an agent anyway.**

| Non-delegation reason | What the agent does | Risk |
|---|---|---|
| External access (credentials, live API) | Hard-fails visibly, cannot proceed | Low — self-enforcing |
| Manual testing | Reports done on unit tests alone | Medium — silent but memorable |
| Design decisions | Picks one, defensibly, moves on | **High** |
| Judgment calls | Same, and the plausibility hides it | **High** |

Only two of the four actually need a guard. The failure mode is never refusal — it is the agent reading "judgement call: which renames to adopt" as *context* rather than as a barrier, picking a reasonable-looking answer, and handing back a green test suite with your decision buried in the diff.

**The technique that follows: name the stop condition, not the reason.** "Judgement call" is a category the model reads past; "when you hit a rename decision, stop and give me options with your recommendation" is an instruction it obeys. One sentence at invocation time beats 574 words of skill — and `disable-model-invocation` makes it safe by construction, because a typed command means the human is always present to add it.

## Ticket legibility — the real defect

The brief is optimised as a contract for the agent, and the human reads it first. Concrete evidence: a `ready-for-human` ticket on brushfeed that **never says why it is human** — upstream keeps that instruction as prose in the skill body with no slot in the template, so it silently gets dropped.

Best practice from both traditions converges. 2026 agentic guidance wants "background, goal, acceptance criteria, constraints" written as issues rather than chats; classic AC guidance wants what-and-why with criteria that "specify what needs to happen, not how it's implemented" — verbatim the agent brief's own behavioural-not-procedural principle. Mapping the classic shape (user story / background / tasks / ACs / out of scope) onto the template leaves **exactly one hole: the why**. `Summary` restates the *what* a second time.

- **Do not import "tasks"** from the classic format. It is the procedural "how" that both traditions rule out, and it is what makes briefs rot as code moves underneath them.
- **`Current behavior` leads with the observable symptom, then the internals** — "share previews and browser tabs still show the old wordmark", not a filename list.
- **Drop the grep clause from `Key interfaces`** ("consumers grepped at brief-writing time so pickup can re-grep"). It existed solely to feed `pickup`; the field itself survives, as it does upstream with no pickup skill.

The technical language was never the problem. Its **position** was.

## Consequences / open threads

- Execution deferred: the map's destination is a decision document, so the ~6-file edit (skills repo `CONTEXT.md`, `README.md`, `AGENT-BRIEF.md`, `triage/SKILL.md`, ADR-0002 superseded, `receive`) belongs to a later effort.
- **`receive` is stranded** — it defines itself as "the session analogue of `/pickup`" and now needs its own justification or none.
- Two `/triage` enhancements identified and **declined** on ladder rung 1 (speculative until the pain is felt): a fourth *stale* discovery bucket (today's three buckets are all inbound, so an already-labelled rotting ticket appears in none), and upstream's `wontfix: already implemented` branch with its by-domain-concept redundancy check.
- Ticket **title** conventions raised and parked — may dissolve once "Why this matters" is line 1 of every brief.

## Related

- [Dual-Track Tracker Adapter](./dual-track-tracker-adapter.md) — the adapter seam that makes "one skill, two trackers" cheap; that grill kept `pickup` as ahead-of-upstream, which this one reverses.
- the 2026-06-10 daily-workflow redesign grill (retired) — the earlier loop redesign this sits downstream of.
- State Machines for Agentic Workflows — the triage roles *are* a state machine; this decides which states earn their place.
- Deleting 95% of Agent Skills (Nick Nisi, WorkOS) — the cut-the-library instinct, applied here with a measurement check first.
