# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Skills compose by **invocation** — one skill may invoke another via the Skill tool (e.g. `/wayfinder` invokes `/align`). **Inlining** (copy-pasting another skill's procedure into your own body) is forbidden. Invocation is a pointer; inlining is duplication that drifts.

**Align**:
The planning lane's entrance, and its only mode — a multi-pass session that turns an idea into a contract stage 2 can cut work from. Retargets the `grilling` interview: one question at a time, facts looked up rather than asked, decisions kept with the operator, and every question woven through a named **Scenario** with a recommendation and a plain-English reason. Runs against an **Alignment artefact** the pass maintains in the ticket's body, and closes each **Pass** with a **Verdict**. Supersedes `grilling`, `grill-me` and `grill-with-docs`.
_Avoid_: grilling, interview, discovery — `/wayfinder` owns fog-charting.

**Pass**:
One `/align` session. The unit of work, not the conversation: each pass raises the **Alignment artefact**'s resolution, from fog to questions to decisions to a settled contract. Carries a number, and re-entry is the normal case rather than a restart.
_Avoid_: iteration, round, session.

**Verdict**:
The judgement an `/align` pass closes with — **aligned** (the gate is met; the artefact is a contract), **fog** (the work is still mostly unknown, but every unresolved item carries what would resolve it, so the routes are the next pass's plan), **dropped** (the work is not worth doing — nothing new is created, and a ticket that exists goes to `wontfix`), or **thin** (unresolved items with no route, axes unmarked, no decisions recorded). Fog is a finding, not an input: which verdict a pass returns is decided at its close, never at invocation. Thin is the failure; fog and thin look identical from outside, and the route is the discriminator.
_Avoid_: confidence, "feels complete".

**Alignment artefact**:
What `/align` maintains in the ticket's **body** — the residue of the conversation, not its transcript. Holds the named **Scenario**s and their outcomes, the settled interfaces, the decision table with its rejected alternatives, the axis marks, out-of-scope, and the unresolved list. Each **Pass** also posts a **comment**: that pass's verdict and delta, its diagrams, the sketches as they stood, and the reasoning. The body is the current truth and stays true to the intention being aligned; the comments are how it got there, and stage 2 reads the body rather than rewriting it.
_Avoid_: transcript, notes, grilling notes.

**Scenario**:
A named, concrete walk through the system — *a publisher posts a carousel of four images* — that every question in an `/align` pass is woven through, so an option shows its impact instead of being argued in the abstract. Enumerated during the pass, and each one ends with an outcome or an unresolved item.
_Avoid_: use case, user story.

**Layer**:
One branch in a `gh stack`, and the pull request that carries it. Cut by *code* dependency — schema, shared types, then their consumers — so a layer is green but not independently valuable. Stage 3 cuts layers; stage 1 cuts **Ticket**s. A layer is never a tracker node.
_Avoid_: slice, sub-task.

**Spec**:
A **destination**, not a stage — one exit an **Align** pass can take, alongside a proposal, direct tickets, an ADR, or nothing at all. The synthesised form of a planned piece of work: problem, solution, user stories, implementation and testing decisions, published to the tracker by `/to-spec`. `/to-spec`, `/to-tickets` and `/to-proposal` are **terminals**; a map's destination names its exit. Supersedes the old *PRD*: the document was never product-only, so "spec" is the honest superset (technical, non-technical, or a blend). A spec publishes as `ready-for-agent` by construction; the planning lane does **not** route it through triage.
_Avoid_: PRD, requirements doc.

**Ticket**:
A tracer-bullet vertical slice of a spec — a narrow but complete path through every layer — declaring its **blocking edges** (the tickets that must close before it can start). Produced by `/to-tickets`, as native tracker links or a local `tickets.md`. The **frontier** is every ticket whose blockers are closed: the work takeable now. Supersedes the old *issue* (which was GitHub/Linear-biased).
_Avoid_: issue, story.

**Specification**:
The structured document `/specifier` publishes to a **Ticket** as an append-only comment — the proven run contract, the criteria, the QA procedures — and the only artefact the gauntlet consumes. Distinct from a **Spec**: a spec is prose a human reads, written before the code exists; a specification is machine-read, and every command in it was executed green in a throwaway worktree during the session that published it. Its publication **is** its approval, structurally — an unpublished one has no address, so the gauntlet cannot reach it.
_Avoid_: conflating with **Spec** (`/to-spec`'s document), or with a **Ticket**'s acceptance criteria — a ticket keeps a plain-prose definition of done and never authors criteria.

**Carriage**:
The gitignored paths a worktree cannot get from git — a local settings file, a certificate, a seed database — declared by the operator during `/specifier`, falsified by its proof run, and frozen into the **Specification** as `contract.carry`. Build output is not carriage: `install` and `build` rebuild it.
_Avoid_: copying, syncing.

**Triage**:
The state-machine move that classifies an *inbound* ticket — a user bug, a collaborator draft, a stale issue — and prepares it for execution. Operates at the issue tracker level, not in the editor. Planned work does **not** pass through triage: `/to-spec` and `/to-tickets` publish `ready-for-agent` by construction. Triage is the lane for work that arrives without an **Align** pass behind it.

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
The verification `/align` completes before declaring a plan ready, and the thing that makes a **Ticket** executable — without it the ticket names nothing that can be opened or grepped. All four passes must run; "the agent had judgment" is not a substitute. The passes themselves live in [the skill](../engineering/align/SKILL.md), which owns them.

**Synced**:
A skill whose local `SKILL.md` is intended to track `mattpocock/skills` byte-for-byte. Divergence is a bug unless a why-line in `CLAUDE.md` says otherwise. Perfect sync is also what lets an upstream-only command name leak in, so a synced file is not a safe file.

**Adapted**:
A skill that started upstream and carries deliberate local changes on top of a recognisable upstream shape. Upstream improvements are expected to land here, hunk by hunk, and every divergence needs a why-line.

**Forked**:
A skill that shares a name or an idea with upstream but not a body — or has no upstream counterpart at all. Upstream diffs are not applied; they are read for ideas only.

## Relationships

- Two lanes reach `ready-for-agent`: the **planning lane** (**align** → **spec** → **ticket**s — an **Alignment artefact** stands behind the contract) and the **inbound lane** (**triage** → **agent brief**, for work that arrived cold). Same label, different provenance. The planning lane is **no longer triage-free**: a ticket born from `/align` waits in `needs-alignment` until stage 2 cuts the work from its body. The inbound lane has no verification step in front of it — `/implement` takes a ticket reference and fetches the brief itself.
- A **triage** session produces an **agent brief** when it moves a ticket to `ready-for-human` or `ready-for-agent`. `ready-for-human` still partitions what an agent can be trusted to finish alone from what it cannot; it just no longer gates on a separate skill.
- **Four-pass discipline** is what makes an **agent brief** executable — without it, the brief names nothing that can be opened or grepped. Apply it *more strictly* for `ready-for-agent`, which has no human reading the brief against the branch.
- A greenfield frontend runs `design-system` twice around a `/prototype`: pass one writes the **DESIGN.md** knobs and tokens with **Motif**s empty, the prototype discovers the flavour on the first real screen, pass two distils the winner into motifs. Discovery is finished when a new screen can be built without `implement` stopping to ask.
- The planning lane stops at the **Ticket**: `/to-tickets` writes a plain-prose definition of done and no criteria. Criteria are authored once, by `/specifier`, against a running repo — a ticket carrying them would create two authorities on "done", and the weaker, older one is the one visible in the backlog.
- **Ticket**s are vertical and **Layer**s are horizontal. Stage 1 cuts tickets — scope, independently valuable, linked by native blocking edges, so the **frontier** stays one flat query. Stage 3 cuts layers — code dependency, green but not independently valuable. One `gh stack` per ticket; one branch and one pull request per layer. A **Ticket** is never a sub-issue: nesting the workflow labels a level down would make `ready-for-agent` a different claim on a parent than on a child.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.

## Flagged ambiguities

- **The ticketing lane shaped gauntlet-fitness** — ADR-0003, plus the **Edge**, **Gauntlet-fitness**, **Unfitness class**, **Grow-the-seam prep ticket**, **Ticket-lint** and **Stamper** terms → resolved: **removed**. `/specifier` is the sole author of acceptance criteria and runs against a live repo with the server up and a test report in hand, so shaping in prose upstream of it produced criteria that *looked* runnable and were therefore trusted. `ticket-lint` no longer exists; ADR-0003 is superseded rather than deleted, and its premise is recorded there.
- **`ready-for-agent` was guaranteed by construction** — ADR-0002, plus the *triage-free planning lane* → resolved: **reversed**. `/align` creates the ticket before it is buildable, so `needs-alignment` is a real intermediate state and the label means *the body is not yet the contract*. Construction promised a label, not a ticket: nothing in it required a named interface, a scenario, or an out-of-scope list. See ADR-0005.
