# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Skills compose by **invocation** — one skill may invoke another via the Skill tool (e.g. `/wayfinder` invokes `/align`). **Inlining** (copy-pasting another skill's procedure into your own body) is forbidden. Invocation is a pointer; inlining is duplication that drifts.

**Align**:
The planning lane's entrance, and its only mode — a multi-pass session that turns an idea into a contract stage 2 can cut work from. Retargets the `grilling` interview: one question at a time, facts looked up rather than asked, decisions kept with the operator, and every question woven through a named **Scenario** with a recommendation and a plain-English reason. Runs against an **Alignment artefact** the pass maintains in the ticket's body, and closes each **Pass** with a **Verdict**. Supersedes `grilling` and `grill-me`.
_Avoid_: grilling, interview, discovery — `/wayfinder` owns fog-charting.

**Pass**:
One `/align` session. The unit of work, not the conversation: each pass raises the **Alignment artefact**'s resolution, from fog to questions to decisions to a settled contract. Carries a number, and re-entry is the normal case rather than a restart.
_Avoid_: iteration, round, session.

**Short pass**:
A **Pass** of one round, raised mid-build or by a case the contract never named, that closes on one of three exits — fixed in this ticket, out of scope, or a new ticket. It keeps the full close: pass count, **Verdict**, **Readiness check**, and an open item in Unresolved rather than a comment. A full pass replaces it when the answer changes what another slice promises.
_Avoid_: amendment, mini-alignment.

**Operator**:
The human the lane serves: owns the contract, supplies what the run cannot reach, runs the acceptance criteria at hand-back, merges the pull request, and retires skills. Not in the loop's per-unit path — a fallback the run reaches for, never a station it waits at.
_Avoid_: user, developer, owner.

**Escalation**:
A message a run sends the **Operator** at one of three levels — **decision** (a choice only they can make), **action** (a yes before something outward happens), **information** (nothing is asked). The level says how soon they need to look; the session is its sink until a notifier exists.
_Avoid_: ping, notification.

**Verdict**:
The judgement an `/align` pass closes with — **aligned** (the gate is met; the artefact is a contract), **fog** (the work is still mostly unknown, but every unresolved item carries what would resolve it, so the routes are the next pass's plan), **dropped** (the work is not worth doing — nothing new is created, and a ticket that exists goes to `wontfix`), or **thin** (unresolved items with no route, axes unmarked, no decisions recorded). Fog is a finding, not an input: which verdict a pass returns is decided at its close, never at invocation. Thin is the failure; fog and thin look identical from outside, and the route is the discriminator.
_Avoid_: confidence, "feels complete".

**Alignment artefact**:
What `/align` maintains in the ticket's **body** — the residue of the conversation, not its transcript. Holds the named **Scenario**s and their outcomes, the settled interfaces, the decision table with its rejected alternatives, the axis marks, out-of-scope, and the unresolved list, and the **Destination** — tickets, a proposal, an ADR, or nothing. Each **Pass** also posts a **comment** carrying only what moved: that pass's verdict and delta, each changed decision as a one-line row, and a diagram per flow the pass touched. A decision whose argument outgrows its row earns an **ADR** on the alignment branch, never comment prose. The body is the current truth and stays true to the intention being aligned; the comments are how it got there, and stage 2 reads the body rather than rewriting it.
_Avoid_: transcript, notes, grilling notes.

**Destination**:
The exit an **Align** pass settles on, carried as a line in the **Alignment artefact**'s header: **tickets** (one **Ticket** graduates, or several with a container parenting them), a **Proposal** (a yes is owed outside the room), an **ADR** (the deliverable is the decision itself), or nothing (dropped, or already recorded). Content, never a label — a property of the work, not of the state — and decided at the close, like the **Verdict**.
_Avoid_: project, spec — a container rides inside the **tickets** value, and is not a destination of its own.

**Cut**:
The stage-2 act — `/cut` reads an aligned body, assigns every **Scenario** to exactly one **Ticket**, and publishes those tickets. It decides nothing: what cannot be written from the contract goes back for an **Align** pass rather than being filled in with prose at the cut. It never cuts horizontally — work that cannot name the scenario it makes pass is horizontal work wearing a ticket's clothes. **The cut is atomic**: no node is written until every slice passes the **Readiness check** and the operator confirms the set; one unwritable slice returns the work to `needs-alignment`.
_Avoid_: breakdown, split.

**Readiness check**:
The ten-row test a body passes before `ready-to-build`: scenarios with outcomes; criteria falsifiable, traced to a scenario, with their command and evidence; every interface owned or consumed; each settled decision with its rejected alternative; out-of-scope with reasons; boundaries (always / ask first / never); no unresolved entries; sources that resolve; native blockers naming real tickets; and every axis marked, the coverage line totalling the list. Its home is `engineering/cut/READINESS.md`; `/cut` applies it to every slice, and `/align`'s close applies it when a single-deliverable contract graduates. Failing any row refuses the stamp.
_Avoid_: gate, definition of done.

**Scenario**:
A named, concrete walk through the system — *a publisher posts a carousel of four images* — that every question in an `/align` pass is woven through, so an option shows its impact instead of being argued in the abstract. Enumerated during the pass, and each one ends with an outcome or an unresolved item.
_Avoid_: use case, user story.

**Impact line**:
The part of a **Scenario** that says what goes wrong, for whom, and how many — counted from data where the data is reachable, otherwise marked "not counted" with the reason. Counted, never rated: it lets an operator weigh a case without knowing the domain.
_Avoid_: severity, priority.

**Axis**:
One dimension of a change every pass must answer for before it can close — happy path, limits, failure, misuse, concurrency and idempotency, permissions, observability, rollback, cost. Each is marked **decision**, **N/A** or **out of scope** with its reason, and the pass closes with one coverage line naming the counts, which total the list.
_Avoid_: dimension, category, checklist.

**Unit**:
The build's quantum — the work one fresh **Builder** invocation takes: a criterion, or a coherent group of them, cut by coherence rather than by the window. When a window fills mid-unit, what is green is committed, the comment records the resume point, and the remainder joins the plan as a unit of its own. Never horizontal: work that cannot name the criterion it makes pass is not a unit.
_Avoid_: layer, chunk — a **Ticket** is a slice, and this is the code's quantum inside one.

**Build**:
Stage 3 — the act that turns a cut **Ticket** into working code: one branch, a sequential loop of **Unit**s, each in a fresh **Builder** invocation, each vetted by **Review** between units, handed back with the commands that show each criterion working. The parent session — the Delegator — holds the contract and the run's one comment rather than a diff, and never builds. One writer per checkout. Succeeds `/implement`, now deprecated.
_Avoid_: implement, execute, run.

**Builder**:
One invocation that builds one **Unit** — never a station that persists. A builder is always fresh: *returned to a fresh builder* means a new invocation carrying the **Finding** as its brief, not a resumed one. It TDDs the unit, committing every red → green → refactor cycle, and ends when it judges the unit done.
_Avoid_: agent, worker, subagent — those are the transport, not the role.

**Fit**:
The act that derives and proves the repo's own mechanics before any code is written — the commands, one per acceptance criterion, the paths a secret lives at (never its value), and the commit and tooling hash they were proven against. Recorded in the session's build comment for that run rather than a separate artefact.
_Avoid_: setup, onboarding, environment.

**FeedbackLoop**:
The repo's own verification, derived and proven at the **fit** before any code is written: typecheck, focused tests, suite. Absent where a repo has none, and absence is a recorded fact rather than a stop; a command, service or secret that is *unavailable* stops the run before it writes. The commands come from the repo on every run, never from a cache.
_Avoid_: pipeline, CI, guard.

**Review**:
The **policy** that vets a diff before it goes anywhere: a **Unit**'s delta as the loop runs, and a named pull request when `/review` calls it. It answers with **Finding**s and the caller owns the sink — a fix round inside **Build**, a draft comment from `/review` — and it never posts. The skill implementing it is `/crucible`; `/review` invokes it and owns the voice and the posting, and `/code-review` is deprecated into it.
_Avoid_: the review seam — *seam* keeps its codebase-design sense — and code review, linting.

**Finding**:
One question **Review** asks, carrying the evidence that raised it: its class, its severity, `found at`, the unit it belongs to, and its resolution. Classes are **behaviour**, **claim**, **test** and **shape**; severities are P0–P2, and only behaviour, claim and test act. Resolved findings are counted in the run's comment and never transcribed into the pull request.
_Avoid_: comment, defect, issue.

**Shepherd**:
The stage after **Build** — takes one pull request from open to ready to merge. It waits for the review bot's round to finish, triages each outside comment — fixed through a fresh **Unit** and **Review**, or answered with evidence — asks for re-review, and sends an **Escalation** for anything that changes the contract. Replies to colleagues are drafted for the **Operator**'s yes. Outside review is input to it, never a second gate, and it never merges (ADR-0010).
_Avoid_: watcher, post-PR loop, relay.

**Spec**:
The container's body, cut by `/cut` when an alignment settles into more than one **Ticket**: the map, not the contract — the scenario-to-slice assignment, and the shared interfaces with the consumers that claim them. It carries no acceptance criteria and no boundaries, so it wears no workflow label and is checked as a map only. Where the tracker has native sub-issues it parents its slices, and it closes when its last slice closes. Supersedes the old *PRD*: the document was never product-only, so "spec" is the honest superset (technical, non-technical, or a blend).
_Avoid_: PRD, requirements doc; and *destination* — the exit is the **Destination**, and a container rides inside its **tickets** value.

**Ticket**:
A tracer-bullet vertical slice cut from an **Alignment artefact**'s body by **Cut**, or from the **Spec** that parents it — a narrow but complete path through every layer — declaring its **blocking edges** (the tickets that must close before it can start). It carries its contract's material verbatim: its **Scenario**s, its acceptance criteria, the interfaces it owns, the diagram it changes, the decisions that bind it, and what was decided against. The **frontier** is every ticket whose blockers are closed: the work takeable now. Supersedes the old *issue* (which was GitHub/Linear-biased).
_Avoid_: issue, story, slice.

**Proposal**:
The decision document `/propose` publishes when an alignment needs someone else's yes — a **Destination** an **Align** pass can take, beside direct tickets and a project. Its publication leaves the ticket in `awaiting-decision`; the outcome routes back to `ready-to-cut` on a yes, to `needs-alignment` with the objections recorded on a change, or to `wontfix` on a no.
_Avoid_: spec — a proposal persuades a decider, a **Spec** tells a builder.

**Specification**:
The structured document published to a **Ticket** as an append-only comment — the proven run contract, the criteria, the QA procedures — and the only artefact the gauntlet consumes. Distinct from a **Spec**: a spec is prose a human reads, written before the code exists; a specification is machine-read, and every command in it was executed green in a throwaway worktree during the session that published it. Its publication **is** its approval, structurally — an unpublished one has no address, so the gauntlet cannot reach it.
_Avoid_: conflating with **Spec** (the container's body), or with a **Ticket**'s acceptance criteria — the ticket's criteria are authored as prose at the **Cut**, and a **Specification** derived from it agrees with them rather than re-inventing them.

**Carriage**:
The gitignored paths a worktree cannot get from git — a local settings file, a certificate, a seed database — declared by the operator during the **Fit**, falsified by its proof run, and frozen into the **Specification** as `contract.carry`. Build output is not carriage: `install` and `build` rebuild it.
_Avoid_: copying, syncing.

**Triage**:
The state-machine move that classifies an *inbound* ticket — a user bug, a collaborator draft, a stale issue — and queues it for the act it needs. Operates at the issue tracker level, not in the editor. It applies `bug`/`enhancement` with one of `needs-triage`, `needs-info`, `needs-alignment`, `wontfix`, and sizes a bug's blast radius from the trace reproduction already reads. It stamps no takeable state, writes no brief, and runs no pass. Planned work does **not** pass through triage: `/align` creates it and `/cut` cuts it. Triage is the lane for work that arrives without an **Align** pass behind it.
_Avoid_: reading `needs-alignment` as a pass that happened — a pass is owed, not paid.

**Sweep**:
A **Triage** run over a whole backlog instead of one ticket. It reads the operator's open inbound tickets, groups them into **Duplicate**s and **Family**s, traces one survivor per group, and writes the whole plan once the operator has confirmed it as a set. It ends with a before → after count and a next-up queue. It stamps no takeable state and runs no pass.
_Avoid_: cluster, batch triage, bulk triage.

**Duplicate**:
A ticket asking for the same fix or the same change as another. The richer one survives; the other closes through the tracker's native duplicate relation, and its unique facts are copied into the survivor.

**Family**:
Separate tickets that touch the same code and would be aligned together. One member survives with a placeholder listing every member; the rest close as its duplicates, and `/cut` separates the family back into slices.
_Avoid_: epic, group — a family is a queueing move, not a container.

**Handoff**:
A continuity doc written by `/handoff` so a fresh session can continue mid-task work. When an Obsidian vault is present it lands in the vault's `Handoffs/`; otherwise a tmp file. Transient — consumed once, then deleted. The vault is transport, not a store.

**Receive**:
Resuming a **Handoff** (`/receive`). Scoped to context transfer *within* a task — a window reset, a worktree crossing — never cross-day continuity.
_Avoid_: "resume", "continue" — reserved session commands in Claude Code and pi.dev; a skill of either name is shadowed by the built-in.

**Placeholder body**:
An inbound ticket's queue form — Background context, Problem statement, and the triage notes — carrying no `Passes:` header, no criteria and no boundaries. Written by **Triage** only where the body cannot already answer those two, and folded into Background by an **Align** pass 1.
_Avoid_: calling it a brief or a contract; it is the queue's shape.

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

**Synced**:
A skill whose local `SKILL.md` is intended to track `mattpocock/skills` byte-for-byte. Divergence is a bug unless a why-line in `CLAUDE.md` says otherwise. Perfect sync is also what lets an upstream-only command name leak in, so a synced file is not a safe file.

**Adapted**:
A skill that started upstream and carries deliberate local changes on top of a recognisable upstream shape. Upstream improvements are expected to land here, hunk by hunk, and every divergence needs a why-line.

**Forked**:
A skill that shares a name or an idea with upstream but not a body — or has no upstream counterpart at all. Upstream diffs are not applied; they are read for ideas only.

## Relationships

- The planning lane is three acts: `/align` → `/cut` → `/build`. `/implement` is deprecated into **Build**, now that stage 3 has run in anger; the inbound lane uses `/build` too. `/build`'s engine is `/crucible`; `/review` invokes the same policy and owns the posting, and `/code-review` is deprecated into it (ADR-0009).
- Two lanes reach the takeable states: the **planning lane** (**align** → **cut** → **ticket**s, with `/propose` as the branch that asks someone first — an **Alignment artefact** stands behind the contract) and the **inbound lane** (**triage** → placeholder, for work that arrived cold). One label set, two provenances. The planning lane is **no longer triage-free**: a ticket born from `/align` waits in `needs-alignment` until `/cut` cuts the work from its body. The inbound lane reaches no takeable state of its own — triage queues, and only a readiness check (`/align`'s close or `/cut`) stamps `ready-to-build`.
- A **triage** session never writes a brief: the contract is the **Alignment artefact**'s body, and an inbound ticket waits in `needs-alignment` for the pass that writes it. Delegability is a body fact, not a state — the takeable pair retired with it.
- A greenfield frontend runs `design-system` twice around a `/prototype`: pass one writes the **DESIGN.md** knobs and tokens with **Motif**s empty, the prototype discovers the flavour on the first real screen, pass two distils the winner into motifs. Discovery is finished when a new screen can be built without stopping to ask.
- The planning lane stops at the **Ticket**: its acceptance criteria are authored from its own **Scenario**s at the **Cut**, and a **Specification** derived from it must agree with them rather than re-invent them — two authorities on "done" is the risk ADR-0004 named and ADR-0006 accepted knowingly.
- **Ticket**s are vertical. The **Cut** produces tickets — scope, independently valuable, linked by native blocking edges, so the **frontier** stays one flat query — and never a horizontal cut, because a slice that cannot name its **Scenario** is horizontal work wearing a ticket's clothes. Stage 3 is one branch with a sequential loop of **Unit**s inside it. A **Ticket** is never a sub-issue of another **Ticket** — nesting the workflow labels a level down would make the takeable claim a different one on a parent than on a child. Its container is the one **Spec** that parents it, which wears no workflow label, so there is no claim to differ from.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.

## Flagged ambiguities

- **The ticketing lane shaped gauntlet-fitness** — ADR-0003, plus the **Edge**, **Gauntlet-fitness**, **Unfitness class**, **Grow-the-seam prep ticket**, **Ticket-lint** and **Stamper** terms → resolved: **removed**. Acceptance criteria are authored at the **Cut**, each with the command and evidence that decide it, so shaping them in prose upstream of that act produced criteria that *looked* runnable and were therefore trusted. `ticket-lint` no longer exists; ADR-0003 is superseded rather than deleted, and its premise is recorded there.
- **The agent-takeable label was guaranteed by construction** — ADR-0002, plus the *triage-free planning lane* → resolved: **reversed**. `/align` creates the ticket before it is buildable, so `needs-alignment` is a real intermediate state and the label means *the body is not yet the contract*. Construction promised a label, not a ticket: nothing in it required a named interface, a scenario, or an out-of-scope list. See ADR-0005.
