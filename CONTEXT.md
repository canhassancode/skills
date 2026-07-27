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
A continuity doc written by `/handoff` so a fresh session can continue mid-task work. When an Obsidian vault is present it lands in the vault's `Handoffs/`; otherwise a tmp file. Transient — consumed once, then archived.

**Receive**:
Resuming a **Handoff** (`/receive`). Scoped to context transfer *within* a task — a window reset, a worktree crossing — never cross-day continuity.
_Avoid_: "resume", "continue" — reserved session commands in Claude Code and pi.dev; a skill of either name is shadowed by the built-in.

**Agent brief**:
The structured comment posted when a ticket reaches `ready-for-anything`. The contract that downstream execution works from. The issue body is context; the brief is canon.

**Surface**:
A concrete code location a piece of work claims to touch — a function, endpoint, resolver, type. Concrete enough to open in an editor. Branches (feature flags, env gates, A/B switches) that gate a surface are part of the surface, not separate from it.

**Consumer**:
A concrete code location that reads a field, type, or behaviour being changed. Found by grep, not by trusting the author's mental model.

**Four-pass discipline**:
The verification work `/grill-with-docs` must complete before declaring a plan ready: (1) trace request paths, don't list modules; (2) grep for consumers; (3) sketch `CONTEXT.md` if missing; (4) check for feature flags / branches that hide parallel surfaces. All four must run; "the agent had judgment" is not a substitute.

**Synced**:
A skill whose local `SKILL.md` is intended to track `mattpocock/skills` byte-for-byte. Divergence is a bug unless a why-line in `CLAUDE.md` says otherwise. Perfect sync is also what lets an upstream-only command name leak in, so a synced file is not a safe file.

**Adapted**:
A skill that started upstream and carries deliberate local changes on top of a recognisable upstream shape. Upstream improvements are expected to land here, hunk by hunk, and every divergence needs a why-line.

**Forked**:
A skill that shares a name or an idea with upstream but not a body — or has no upstream counterpart at all. Upstream diffs are not applied; they are read for ideas only.

## Relationships

- Two lanes reach `ready-for-agent`: the **planning lane** (grill → **spec** → **ticket**s, triage-free — a grilling stands behind the brief) and the **inbound lane** (**triage** → **agent brief**, for work that arrived cold). Same label, different provenance. Both lanes survive; the inbound one no longer has a verification step in front of it — `/implement` takes a ticket reference and fetches the brief itself.
- A **triage** session produces an **agent brief** when it moves a ticket to `ready-for-human` or `ready-for-agent`. `ready-for-human` still partitions what an agent can be trusted to finish alone from what it cannot; it just no longer gates on a separate skill.
- **Four-pass discipline** is what makes an **agent brief** executable — without it, the brief names nothing that can be opened or grepped. Apply it *more strictly* for `ready-for-agent`, which has no human reading the brief against the branch.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.
