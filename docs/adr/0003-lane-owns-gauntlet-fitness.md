---
status: accepted
---

# The ticketing lane owns gauntlet-fitness

The gauntlet was expected to return a "not gauntlet work" verdict when a ticket could not be driven to green, and a live run (brushfeed#110) jammed twice this way — discovering unfitness only after ~40 minutes of looping. We decided the **ticketing lane owns gauntlet-fitness**: every skill that stamps `ready-for-agent` (`/to-spec`, `/to-tickets`, `/triage`) runs a deterministic `run.py ticket-lint` first, and the gauntlet never discovers unfitness at run time.

`ticket-lint` is **shape + class-A only, config-independent**. Of the three unfitness classes, only **A** (no externally observable behaviour) is decidable deterministically from the ticket alone — it is a property of the *ticket* and routes to `/implement`. **B** (a real outcome reachable at no **Edge** the repo serves) and **C** (deliverable lives entirely in `protectedPaths`) cannot be classified at authoring time: proven against `run.py`, `ticket.json` is `{issue,title,body}` only — reachability needs the added-files git diff and `protectedPaths` has no `run.py` evaluator (it is the `gauntlet-protected-paths.sh` `PreToolUse` hook). So B is not a lint verdict but a **specify-stage escalation** that emits a grow-the-seam prep ticket, and C stays the deferred protected-paths hook. The lint emits `{fit, class: "A"|null}` and nothing else.

## Considered Options

- **Gauntlet returns "not gauntlet work" at run time** — rejected. It discovers unfitness after the run has already burned time, and hands the ambiguous work that most needs guardrails to the ungated `/implement`.
- **A prose-only check in `CLAUDE.md`** — rejected. Prose-only is exactly the failure the gauntlet-leak exists to kill; the check must be mechanical (`ticket-lint`), with `CLAUDE.md` carrying only policy and the global on/off switch.
- **Embed the fitness logic in every lane skill** — rejected. The shape+A logic lives once in `run.py ticket-lint`; the three stampers each call it, and upstream skills (`/grilling`, `/grill-with-docs`, `/wayfinder`) route into a stamper and inherit it rather than embedding a conditional. This keeps `wayfinder` byte-synced with upstream.
- **Two-tier `ticket-lint` (shape+A always, B/C when `.gauntlet/config.json` present, degraded otherwise)** — rejected. Building B/C from ticket text deterministically is impossible (see above); doing it "when config is present" would need an LLM-in-guard, the exact anti-pattern the gauntlet redesign killed. Config-independent shape+A is the only honest deterministic gate, so the config-dependent tier and the degraded mode are dropped.

## Consequences

- Cross-repo by construction: the check is `run.py` (dotfiles), the policy is global `CLAUDE.md`, the callers are skills. `ticket-lint` runs early (skippable) in the lane and again unskippably at **Preflight**.
- Two mouths, one gate: the planning lane gates at **spec**/**ticket**, the inbound lane at **triage** (see ADR-0002).
- `ticket-lint` is repo-agnostic: it needs no `.gauntlet/config.json` and returns the same verdict in any repo, so ticket-writing is never blocked on a not-yet-gauntletised repo.
- B and C are surfaced downstream, not at the stamp: B as a specify-stage escalation, C as the deferred `gauntlet-protected-paths.sh` hook.
