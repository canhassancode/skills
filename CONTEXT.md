# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Skills compose by **invocation** — one skill may invoke another via the Skill tool (e.g. `grill-me` invokes `/grilling`). **Inlining** (copy-pasting another skill's procedure into your own body) is forbidden. Invocation is a pointer; inlining is duplication that drifts.

**Spec**:
A **destination**, not a stage — one exit a grilling can take, alongside a proposal, direct tickets, an ADR, or nothing at all. The synthesised form of a planned piece of work: problem, solution, user stories, implementation and testing decisions, published to the tracker by `/to-spec`. `/to-spec`, `/to-tickets` and `/to-proposal` are **terminals**; a map's destination names its exit. Supersedes the old *PRD*: the document was never product-only, so "spec" is the honest superset (technical, non-technical, or a blend). A spec publishes as `ready-for-agent` by construction; the planning lane does **not** route it through triage.
_Avoid_: PRD, requirements doc.

**Ticket**:
A tracer-bullet vertical slice of a spec — a narrow but complete path through every layer — declaring its **blocking edges** (the tickets that must close before it can start). Produced by `/to-tickets`, as native tracker links or a local `tickets.md`. The **frontier** is every ticket whose blockers are closed: the work takeable now. Supersedes the old *issue* (which was GitHub/Linear-biased).
_Avoid_: issue, story.

**Triage**:
The state-machine move that classifies an *inbound* ticket — a user bug, a collaborator draft, a stale issue — and prepares it for execution. Operates at the issue tracker level, not in the editor. Planned work does **not** pass through triage: `/to-spec` and `/to-tickets` publish `ready-for-agent` by construction. Triage is the lane for work that arrives without a grilling behind it.

**Handoff**:
A continuity doc written by `/handoff` so a fresh session can continue mid-task work. When an Obsidian vault is present it lands in the vault's `Handoffs/`; otherwise a tmp file. Transient — consumed once, then deleted. The vault is transport, not a store.

**Receive**:
Resuming a **Handoff** (`/receive`). Scoped to context transfer *within* a task — a window reset, a worktree crossing — never cross-day continuity.
_Avoid_: "resume", "continue" — reserved session commands in Claude Code and pi.dev; a skill of either name is shadowed by the built-in.

**Agent brief**:
The structured comment posted when a ticket reaches `ready-for-anything`. The contract that downstream execution works from. The issue body is context; the brief is canon.

**Surface**:
A concrete code location a piece of work claims to touch — a function, endpoint, resolver, type. Concrete enough to open in an editor. Branches (feature flags, env gates, A/B switches) that gate a surface are part of the surface, not separate from it.

**Consumer**:
A concrete code location that reads a field, type, or behaviour being changed. Found by grep, not by trusting the author's mental model.

**Design system**:
The split that lets every project look consistent while each keeps its own character. The **system** — spacing scale, mandatory states, type ceilings, motion policy — is invariant, lives in `design-system/SYSTEM.md`, and is never interviewed about. The **flavour** — palette, typeface, radius, density, **Motif**s — is per repo and lives in `DESIGN.md`. The system is agreed upfront because it is numbers; the flavour's motifs are deferred because prose cannot hold them.
_Avoid_: style guide, brand guidelines.

**DESIGN.md**:
The visual sibling of `CONTEXT.md` — intent and reasoning for one **brand**, at the highest path governing every surface it covers. Holds no value that also exists in code; the token layer is canon for values, this file for why. One per brand, never one per app: density variation is a row in its `Surfaces` table.

**Motif**:
A named flavour rule carrying two fields — the rule and its **build route** (CSS, GSAP, off-the-shelf component, or bespoke). Earned by distilling a winning `/prototype` variant, never imagined in an interview. A motif without a build route is unfinished; a motif that cannot be checked against a screen ("flashy") is not a motif.

**Four-pass discipline**:
The verification work `/grill-with-docs` must complete before declaring a plan ready: (1) trace request paths, don't list modules; (2) grep for consumers; (3) sketch `CONTEXT.md` if missing; (4) check for feature flags / branches that hide parallel surfaces. All four must run; "the agent had judgment" is not a substitute.

**Synced**:
A skill whose local `SKILL.md` is intended to track `mattpocock/skills` byte-for-byte. Divergence is a bug unless a why-line in `CLAUDE.md` says otherwise. Perfect sync is also what lets an upstream-only command name leak in, so a synced file is not a safe file.

**Adapted**:
A skill that started upstream and carries deliberate local changes on top of a recognisable upstream shape. Upstream improvements are expected to land here, hunk by hunk, and every divergence needs a why-line.

**Forked**:
A skill that shares a name or an idea with upstream but not a body — or has no upstream counterpart at all. Upstream diffs are not applied; they are read for ideas only.

### Gauntlet fitness

The seam vocabulary these terms lean on — **Edge**, **Surface**, `protectedPaths`, **Preflight** — is the gauntlet's, defined in dotfiles `CONTEXT.md`; the fitness concepts here reference it across the context boundary.

**Gauntlet-fitness**:
Whether a **Ticket** can be driven through the gauntlet to green — decided by the lane at authoring time, never discovered by the gauntlet at run time.
_Avoid_: "not gauntlet work" as a run-time verdict — a jam is a lane miss, not a gauntlet limitation.

**Unfitness class**:
Why a ticket is not gauntlet-fit, one of three — but only **A** is decidable at authoring time. **A** — no externally observable behaviour (rename, pure config, copy): the only irreducible case, a property of the ticket, decided by **ticket-lint** and routed to `/implement`. **B** — a real outcome reachable at no **Edge** the repo serves — is **not** an authoring-time verdict (it needs the repo's served surfaces, which `ticket.json` cannot see); it surfaces later as a **specify-stage escalation** that emits a **grow-the-seam prep ticket**. **C** — the deliverable lives entirely in `protectedPaths` — is the deferred `gauntlet-protected-paths.sh` `PreToolUse` hook's concern, out of the lint's scope. Neither B nor C is ever a `ticket-lint` output.

**Grow-the-seam prep ticket**:
The make-this-testable ticket a class-**B** miss produces at the **specify stage** — declare an **Edge** / `serve.surfaces` so the original ticket becomes fit. A run-time remedy, not an authoring-time lint route, and never a handoff to the ungated `/implement`.

**Ticket-lint**:
The deterministic fitness backstop (`run.py ticket-lint`) that runs **unskippably at Preflight** as `PREFLIGHT_GUARDS[0]`, before any stage: checks scenario shape and flags class **A** only. **Shape+A, config-independent** — it reads `ticket.json` alone, never `.gauntlet/config.json`, and makes no seam-relative (B/C) judgement, because neither is decidable deterministically from the ticket. Verdict: `{fit, class: "A"|null}` — fit → proceed, A → escalate to `/implement`. It is a **backstop, not an authoring-time gate**: a class-A ticket fails at the first Preflight guard in seconds rather than jamming the specify stage. The **stampers do not call it** — they shape criteria so the check passes by construction (see *Stamper*).

**Stamper**:
A skill that publishes `ready-for-agent` — `/to-spec`, `/to-tickets`, `/triage`. A stamper **shapes** fitness rather than gating it: it writes each criterion as an observable outcome against a seam the running system **serves** (the gauntlet's **Edge**), so the ticket is gauntlet-fit by construction. No stamper runs `ticket-lint` — the mechanical check lives once, at **Preflight**. `/grilling`, `/grill-with-docs` and `/wayfinder` never stamp — they route into a stamper and inherit the shaping. `/to-tickets` is the primary home of the seam vocabulary (it authors the Given/When/Then criteria); `/to-spec` carries the light form (it sketches the test seam a slice will attach to).

## Relationships

- Two lanes reach `ready-for-agent`: the **planning lane** (grill → **spec** → **ticket**s, triage-free — a grilling stands behind the brief) and the **inbound lane** (**triage** → **agent brief**, for work that arrived cold). Same label, different provenance. Both lanes survive; the inbound one no longer has a verification step in front of it — `/implement` takes a ticket reference and fetches the brief itself.
- A **triage** session produces an **agent brief** when it moves a ticket to `ready-for-human` or `ready-for-agent`. `ready-for-human` still partitions what an agent can be trusted to finish alone from what it cannot; it just no longer gates on a separate skill.
- **Four-pass discipline** is what makes an **agent brief** executable — without it, the brief names nothing that can be opened or grepped. Apply it *more strictly* for `ready-for-agent`, which has no human reading the brief against the branch.
- A greenfield frontend runs `design-system` twice around a `/prototype`: pass one writes the **DESIGN.md** knobs and tokens with **Motif**s empty, the prototype discovers the flavour on the first real screen, pass two distils the winner into motifs. Discovery is finished when a new screen can be built without `implement` stopping to ask.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.
- **Gauntlet-fitness** threads the lane: ambient policy (global `CLAUDE.md`) → **shaped** in a build-bound **grilling** and at the **stampers** (criteria written against a served **Edge**) → **guaranteed** unskippably at **Preflight** by **ticket-lint**. The lane shapes; Preflight backstops. Only `ticket.json` transits as data; upstream shape is advice re-derived at each stamper.
- Both lanes that reach `ready-for-agent` **shape** for fitness — the planning lane at **spec**/**ticket**, the inbound lane at **triage** — and both are backstopped by the single **ticket-lint** at Preflight. Two mouths shape; one guard verifies.
- The three **Unfitness class**es split by ownership and by *when* they are seen: **A** is the ticket's, caught deterministically at **Preflight** by **ticket-lint** (→ `/implement`) and shaped against at authoring time by the stampers; **B** is repo config's, seen only at the **specify stage** (→ **grow-the-seam prep ticket**); **C** is the deferred protected-paths hook's. Only **A** is a lint verdict. dotfiles#57's `serve.surfaces` converted a class-**B** jam into a bindable **Surface**.

## Flagged ambiguities

- **"not gauntlet work"** was a verdict the gauntlet returned on a live run → resolved: abolished except class **A**, the one class fixed at authoring time. **B**/**C** are "not fit *yet*, pending a seam the operator grows," surfaced downstream (B at specify, C at the protected-paths hook), never gauntlet limitations and never `ticket-lint` outputs.
- **`ticket-lint` was speced two-tier** (shape+**A** always, **B**/**C** when `.gauntlet/config.json` present, degraded otherwise) → resolved: **shape+A only, config-independent**. Proven against `run.py` — `ticket.json` is `{issue,title,body}`, so a deterministic guard cannot classify B (needs served surfaces) or C (needs a `protectedPaths` evaluator that lives in the hook, not `run.py`). The config-dependent tier and the degraded mode dissolved with it.
- **`ticket-lint` was to be embedded in the three stampers** (skills#42) → resolved: **dropped**. Once shrunk to shape+A, the stamper call re-asks the exact yes/no Preflight already asks unskippably `PREFLIGHT_GUARDS[0]` a moment later — a checkpoint, not a metric move (success metric: never jam the gauntlet mid-run). The lane instead **shapes** for fitness (criteria against a served **Edge**), which the mechanical check cannot do; Preflight is the sole backstop. Reverses ADR-0003's "the lane *owns* fitness (every stamper runs the gate)" to "**Preflight owns fitness; the lane shapes it**." skills#42 closed, skills#41 re-pointed.
