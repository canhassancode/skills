---
created: 2026-07-27
updated: 2026-07-27
sources: "Grill session 2026-07-27 (wayfinder map #4, ticket #12) · drift audit `docs/research/upstream-skills-drift.md`"
---

# Upstream Skill Fork Policy (grill)

What relationship the local skill library (`~/Repos/skills`) should have with `mattpocock/skills`, decided on ticket #12 of the skills + second-brain wayfinder map. Grill-sourced, no raw.

## Two premises that had to die first

**"Upstream got thinner, the fork stayed fat."** False. Aggregate is near-parity — upstream 22 skills / 16,211 words vs local 26 / 18,377. The four skills that collapsed (`grill-with-docs`, `grill-me`, `grilling`, `implement`) collapsed in a *single* upstream move that extracted `grilling` as a shared primitive and made the others compositions over it. Total prose in that family is roughly conserved; it just stopped being duplicated three times. **Deduplication, not deletion.**

**"Track or diverge."** Not a live choice, and never was about size. There is no git fork point — the library was a copy-paste import into a fresh repo, zero shared commit objects, `git merge-base` undefined. Merging is blocked three ways: no common ancestor, divergent paths, and ~40% semantic divergence on shared skills. So the only real question is *what upstream is for*.

## The decision

**Upstream is a harvest feed with a bounded claim, swept on demand.**

It has a **standing claim on the mode-independent primitives** — diagnosis, prototyping, architecture review, ticket generation — where local staleness is pure decay with no adaptive story. It has **no claim on the planning skills**, where the working-mode measurement says the two libraries are aimed at different loops: Matt is triage-heavy (82 triage-labelled / 13 wayfinder), Hassan is the inverse (50 wayfinder / 4 triage).

Source-of-truth was never available — it would mean re-litigating every deliberate local divergence on every pass. Inspiration-only is the status quo, and the status quo is *how the rot happened*: a dangling skill reference shipped in the most-used skill, and the diagnosis skill sat eleven weeks behind a substantial rewrite.

## Three classes, not two

Binary *harvest / forked* forces a false choice on the ~40% of skills that are **additively divergent** — upstream's text plus a local block on top. Calling those forked freezes the largest, most-used skills; calling them harvest re-opens the local additions every pass.

- **Synced** — take upstream wholesale.
- **Adapted** — take upstream's changes to the shared body, keep the local block on top.
- **Forked** — upstream has no claim (everything second-brain-facing, the tracker adapters, commit/PR, the personal bucket).

**Tested before committing, because the middle class only works if the local content is separable.** Five of six adapted skills are 1–3 diff hunks of *appended sections* over a short shared prefix — "keep the local block on top" is literally true. `triage` is the outlier at 12 hunks: about five are pure-add sections, but seven collide at line level inside the numbered flow, where upstream's redundancy check and `wontfix` restructure land on the exact lines rewritten locally. `triage` needs a judged merge, not a mechanical one.

## The failure the middle class exists to catch — already on the record

`grilling`'s shared prefix has **regressed**. Local reads *"exploring the codebase"* and *"design tree"* where upstream reads *"exploring the environment"* and *"decision tree"* — both deliberate upstream generalisations. The local Obsidian blocks were appended to a file whose upstream body had moved underneath them, and nothing was watching.

Generalisable: **appending to a forked file silently rebases nothing.** The additions look clean in the diff precisely because they don't touch the body — which is why body regression is invisible to the person making the addition.

## Rung 1 killed the machinery

A `/sync` skill was designed in the session and then rejected: baseline SHA, a rejected-hunk ledger, and a scheduled job that would open an inbound issue when upstream moved a tracked skill. All of it solved a problem that a **written record plus an on-demand sweep** already solves at this library size.

Hassan's call, and the right one: *"I have a handful of skills, a sweep here is more than enough."*

One piece of mechanism survived — **the upstream remote** — because it is the difference between a sweep being a two-minute diff and a half-hour temp-dir clone. It changes no workflow.

**Reusable test:** machinery earns its place only if it does something the record can't. A ledger of rejected hunks is a *prose note about why this skill diverges*, written once, costing fifteen lines. A schedule is a substitute for a trigger — and a better trigger already existed.

## The trigger: edit-time, not calendar-time

Editing a synced or adapted skill file means **diff against upstream first, prune, then edit**.

This is the moment you already have that skill's full context loaded, so the check is near-free — and it is the exact moment the `grilling` regression happened. A calendar trigger would have caught it too, at the cost of a scheduled job and a ritual to remember.

Honest limit, recorded rather than hidden: on-edit only reaches skills you touch, and all the measured decay is in skills you *don't*. That residue is what the deliberate sweep is for.

## The record, not the ritual

The artifact is a section in the skills repo's `CLAUDE.md`: origin (copy-paste import, no shared history, plus the content baseline), the three-way class list per skill, and **short why-lines on adapted and forked skills only**.

The why-lines are the cheap prose form of the rejected-hunk ledger — they stop a future session deleting local additions as drift, or re-opening a divergence already settled. The three class terms also go into the repo's `CONTEXT.md` glossary: they name a property of files that live in this repo, which is what a glossary is for.

## Where the "thinning" question actually landed

Not on word count. The real upstream signal is a **maintained pruning discipline** with named failure modes — *sediment* (stale layers that settle because adding feels safe and removing feels risky), *no-op* (a line the model already obeys by default, so you pay context to say nothing), *sprawl* (too long even when every line is live) — hunted sentence by sentence, run as a routine editing pass rather than a one-off purge.

**The doctrine is already in the local library**, byte-synced, in the skill-writing skill. **Nothing has ever run it.** That is how one grill skill carries a 600-word block upstream reduced to a sentence, and how two overlapping review skills sat side by side for eight weeks with ~2,800 words of duplication.

So the adoption is not "delete prose to match upstream's size" — it's *running the pass you already own*, wired into the same edit-time line as the upstream diff.

## Sequencing beat merit once

An upstream-style **router skill** — one user-invoked skill naming every other and when to reach for it — was argued for by the drift audit and rejected here **on sequencing, not merit**. Thirty-odd skills with no index is a real cognitive-load problem. But the second half of the same map is about to change the inventory: six dead personal skills, two deprecations, one parked. A router built over a mid-prune inventory points at skills that won't exist. Re-tested after the prune.

## Related

- [Inbound Triage Lane & Ticket Legibility](./inbound-triage-lane-and-ticket-legibility.md) — the ticket before this one on the same map; its "measurement artefact" reframe is the same shape as this one's dead premises.
- [Dual-Track Tracker Adapter](./dual-track-tracker-adapter.md) — its claim that drift from an upstream template is *outgrowing, not failing* is refined here: mostly true, but the audit found real one-way decay too.
- Deleting 95% of Agent Skills (Nick Nisi, WorkOS) — the audit checked whether upstream's pruning follows Nisi and concluded it doesn't; see the note on that page.
- State Machines for Agentic Workflows — the enforcement layer this whole library still lacks.
