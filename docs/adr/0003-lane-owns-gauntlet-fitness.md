---
status: accepted
---

# Preflight owns gauntlet-fitness; the ticketing lane shapes it

The gauntlet was expected to return a "not gauntlet work" verdict when a ticket could not be driven to green, and a live run (brushfeed#110) jammed twice this way — discovering unfitness only after ~40 minutes of looping. The fix has two halves that must not be conflated:

- **The guarantee is `ticket-lint` at Preflight.** `run.py ticket-lint` is `PREFLIGHT_GUARDS[0]` and config-bypassed, so on any `/gauntlet` fire a class-A ticket (no Given/When/Then criteria) fails at the very first guard in seconds — before clean-tree, install, setup, build, coverage, and before any Opus stage — and escalates to `/implement`. This is what actually kills the jam: without it, the earliest catch is the `spec` gate *after* the specify stage runs, which burns full environment bring-up plus up to three specify attempts before `specify: exhausted`. Preflight converts a mid-run jam into a first-guard escalation.
- **The lane's contribution is shaping, not gating.** The stampers (`/to-tickets`, `/to-spec`, `/triage`) already author criteria as observable Given/When/Then outcomes (`to-tickets` line 38) and already sketch test seams (`to-spec` step 2). The lane's job is to write those criteria against a seam the running system **serves** (the gauntlet's **Edge**) so the ticket is fit *by construction*. That shaping is prose the human-and-agent perform with codebase context; a deterministic guard cannot do it.

**Decision: Preflight owns fitness as the single deterministic backstop; the ticketing lane owns fitness only by shaping.** The mechanical `ticket-lint` check lives once, at Preflight. No stamper calls it. This reverses the earlier decision (that every skill stamping `ready-for-agent` runs `ticket-lint` first): once `ticket-lint` shrank to shape+class-A only, a stamper-embedded copy re-asks the exact yes/no question Preflight asks unskippably a moment later — a redundant checkpoint that does not move the success metric (never jam the gauntlet mid-run), while the shaping the lane *can* uniquely provide is not a `ticket-lint` call at all.

## Considered Options

- **Embed `ticket-lint` in the three stampers (skills#42)** — rejected. After the shape+A correction it duplicates the unskippable Preflight guard; the class-A ticket it would catch fails at `PREFLIGHT_GUARDS[0]` in seconds regardless. Three copies of one yes/no check for an authoring-time convenience Preflight already delivers.
- **Revert the Preflight `ticket-lint` guard entirely** — rejected. It is the half that moves the metric: remove it and a class-A ticket jams the specify stage after full env bring-up. The guarantee has to live somewhere deterministic, and Preflight is the unskippable point.
- **Make the stampers gauntlet-aware by embedding a machine gate** — rejected as a category error. The stampers' unique value is *shaping* criteria toward a served **Edge** — prose, informed by codebase research — not re-running a boolean the guard already owns.
- **Make `/wayfinder` gauntlet-aware** — rejected. Its four ticket types (`research`, `prototype`, `grilling`, `task`) are all decision-support, never build-tickets; build work leaves via a `grilling`-type ticket into a stamper (which shapes it) or a `task` into `/implement`. It never hands the gauntlet a ticket, and it is Synced with upstream — a divergence would clobber on every harvest for no gain.

## Consequences

- **One mechanical check, one home.** `ticket-lint` exists once, at Preflight (`run.py`, dotfiles). Nothing calls it from a skill. The shape+A logic cannot drift because there is only one copy.
- **The lane shapes, in prose.** `/to-tickets` is the primary home of the seam vocabulary (it authors the criteria); `/to-spec` carries the light form (it sketches the seam a slice attaches to); `/grill-with-docs` shapes build-bound criteria toward served **Edge**s during the four-pass discipline (skills#43). `/grilling` and `/wayfinder` route into a stamper and inherit the shaping.
- **Global `CLAUDE.md`** carries policy and the on/off switch only: "Preflight enforces fitness; a class-A ticket routes to `/implement`; the lane shapes criteria toward a served Edge."
- **B and C are unchanged:** B surfaces as a specify-stage escalation (grow-the-seam prep ticket), C stays the deferred `gauntlet-protected-paths.sh` hook. Neither is a `ticket-lint` output.
- **Cross-repo by construction:** the guard is `run.py` (dotfiles), the policy is global `CLAUDE.md`, the shaping is in the skills.
