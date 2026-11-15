# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Skills compose by **invocation** — one skill may invoke another via the Skill tool (e.g. `/build` invokes `/crucible`). **Inlining** (copy-pasting another skill's procedure into your own body) is forbidden. Invocation is a pointer; inlining is duplication that drifts.

**Operator**:
The human the lane serves: answers align's rounds and gives the one yes on the spec, supplies what a run cannot reach, rules on each Verify step a build couldn't tick and each item on a pull request's hand-back list, merges, and retires skills. Not in a build's path — a fallback the run stops for; the one wait is those rulings, at hand-back.
_Avoid_: user, developer, owner.

**Align**:
The planning lane's entrance: tier the ask, red-team it, grill it in rounds and write the **Spec** once from the conversation, so the build has nothing left to decide. Every question follows `grilling`; facts come from subagents, never from the operator. A big or foggy ask runs across sessions, each carried on by a **Session comment**'s Resume line; a build that stops on a criterion that can't hold comes back here.
_Avoid_: grilling, interview, discovery, pass.

**Tier**:
Where an ask sits on two questions: does it fit one session, and does anyone know enough to spec it? Size decides **Parent** or **Child**; uncertainty decides whether to explore first. Above the grid, a one-sentence diff needs no plan, nor does a change to one or two files with nothing left to decide. Home: `engineering/align/references/tiers.md`.
_Avoid_: complexity, t-shirt size.

**Spike**:
One question about how something behaves, answered by the smallest throwaway code that shows it inside a 15-minute timebox, with sandbox credentials only. Returns the answer and its evidence; the code is never kept. A fact written down somewhere is `/research`'s; a shape the operator must see is `/prototype`'s.
_Avoid_: probe, experiment, prototype.

**Red team**:
A fresh subagent briefed to argue against the ask before the spec is written, returning **go**, **shrink** or **no-go**. The operator decides; a no-go ends at `wontfix`.
_Avoid_: review, critique.

**Spec**:
The plan for one capability, held as its **Ticket**'s body and never carrying status. Two shapes: a **Parent** and a **Child**. The answers it rests on live in its Decisions, one line each. Supersedes the old *PRD* and the alignment body.
_Avoid_: PRD, contract, requirements doc.

**Parent**:
A spec too big for one session: the Goal, Out of scope, the Shape and seams every child builds into, the Rules every child follows, the Journeys and the Children list. It has no branch, and its ticket wears `ready-to-cut` until `/cut` publishes the children.
_Avoid_: epic, container, project.

**Child**:
A spec that fits one fresh `/build` session — one tracer bullet a user or caller could notice on its own, with about six **Acceptance criteria**, tested at one seam. Carries What to build, Acceptance criteria, Seams, **Verify**, Out of scope and Decisions. Vertical, never a layer.
_Avoid_: slice, story, task.

**Acceptance criterion**:
One plain sentence in a child's Acceptance criteria, observable from outside, saying what the capability does in a case that matters. `/build` writes a test for each, and crucible checks each against the diff. An "always" or "never" criterion becomes a property test.
_Avoid_: behaviour line, scenario, requirement.

**Verify**:
A child spec's section saying how to see the change working on the running app — the start command with the credentials it needs, then each request or page and what it shows. `/build`'s **Verifier** runs the steps before the pull request opens; a step that can't run in session goes into the pull request as an unchecked box with its reason, and keeps it a draft. `none — <why>` is allowed.
_Avoid_: QA, manual test, acceptance.

**Cut**:
`/cut` publishes a parent's Children list as sub-issues at `ready-to-build`, in build order, each a tracer bullet with its acceptance criteria, seams and Verify steps drawn only from the parent and sized for one fresh build session, with blocking edges set as each lands. It decides nothing: something the parent doesn't cover is a question, and a child with a genuinely open question goes to `needs-alignment` instead.
_Avoid_: breakdown, split, slicing.

**Build**:
The act that turns one ticket into a pull request, in one session with one writer: it fits the loop, has a subagent search for what already exists, builds test-first at the spec's seams, has the **Verifier** prove each criterion on the running app, self-reviews against the coding rules, then runs **crucible** at most twice — once over the branch, once over the fix commits. Subagents only read. Stops instead of working around missing access, a criterion that can't hold as written, or a fix that would change the spec. A ticket that fills its window carries over on a Resume line in the pull request. Succeeds `/implement`, now deprecated.
_Avoid_: implement, execute, run.

**Verifier**:
A fresh subagent that runs a child's **Verify** steps against the running app without ever reading the code or the tests, reporting each step passed, failed or not run.
_Avoid_: QA, tester.

**Review**:
The **policy** that vets a diff before it goes anywhere: a build's branch, a shepherd's fix, or a named pull request. Implemented by `/crucible`, which never edits the caller's tree and never posts; `/review` owns the voice and the posting, `/shepherd` the bot's rounds, and `/code-review` is deprecated into it.
_Avoid_: the review seam — *seam* keeps its codebase-design sense — and code review, linting.

**Finding**:
One question **Review** asks, carrying the evidence that raised it. Its class is **spec**, **behaviour**, **boundary**, **claim** or **rule** (a broken `CLAUDE.md` rule); its route is **fix**, **spec-change** (acting would change an acceptance criterion, so `/align`), **product-call** (the operator's, with a safe default) or **suppressed** (the spec or a settled thread already decided it). A baseline smell is a note, never a finding.
_Avoid_: comment, defect, issue, severity.

**Prune list**:
Crucible's list of the tests this diff added that kill no mutant the other tests miss, returned only when mutation runs. Tests older than the diff are never on it.
_Avoid_: dead tests, cleanup.

**Ticket**:
A tracker node. Its body is the **Spec**, a parent's or a child's, written by `/align` or `/cut`. Its label is the work's state. The **frontier** is every ticket whose blockers are closed: the work takeable now.
_Avoid_: issue, story.

**Session comment**:
The one comment each `/align` or `/cut` session posts on its ticket, carrying only what moved. An align session that stops before the spec is written ends with a Resume line naming the open frontier the next session starts from. A build carries over on a Resume line in its pull request body instead.
_Avoid_: log, transcript, status update.

**Proposal**:
The decision document `/propose` publishes when a spec needs someone else's yes. Its publication leaves the ticket in `awaiting-decision`; a yes or a change returns it to `needs-alignment` with the answer posted, and a no to `wontfix`.
_Avoid_: spec — a proposal persuades a decider, a **Spec** tells a builder.

**Specification**:
Forge's structured document published to a **Ticket** as an append-only comment — the proven run contract, the criteria, the QA procedures — and the only artefact the gauntlet consumes. Forge still runs the old pipeline (ADR-0011), so this term belongs to it, not to `/build`.
_Avoid_: conflating with **Spec**.

**Carriage**:
The gitignored paths a forge worktree cannot get from git — a local settings file, a certificate, a seed database — declared by the operator, falsified by a proof run, and frozen into the **Specification** as `contract.carry`. Build output is not carriage: `install` and `build` rebuild it.
_Avoid_: copying, syncing.

**Triage**:
The state-machine move that classifies an *inbound* ticket — a user bug, a collaborator draft, a stale issue — and queues it for the act it needs. Operates at the issue tracker level, not in the editor. It applies `bug`/`enhancement` with one of `needs-triage`, `needs-info`, `needs-alignment`, `wontfix`, and sizes a bug's blast radius from the trace reproduction already reads. It stamps no takeable state, writes no spec, and runs no `/align`. Planned work does **not** pass through triage: `/align` creates it and `/cut` publishes its children.
_Avoid_: reading `needs-alignment` as alignment that happened — it is owed, not paid.

**Sweep**:
A **Triage** run over a whole backlog instead of one ticket. It reads the operator's open inbound tickets, groups them into **Duplicate**s and **Family**s, traces one survivor per group, and writes the whole plan once the operator has confirmed it as a set. It ends with a before → after count and a next-up queue. It stamps no takeable state and runs no `/align`.
_Avoid_: cluster, batch triage, bulk triage.

**Duplicate**:
A ticket asking for the same fix or the same change as another. The richer one survives; the other closes through the tracker's native duplicate relation, and its unique facts are copied into the survivor.

**Family**:
Separate tickets that touch the same code and would be aligned together. One member survives with a placeholder listing every member; the rest close as its duplicates, and `/align` decides whether it is one child or a parent.
_Avoid_: epic, group — a family is a queueing move, not a container.

**Handoff**:
A continuity doc written by `/handoff` so a fresh session can continue mid-task work. When an Obsidian vault is present it lands in the vault's `Handoffs/`; otherwise a tmp file. Transient — consumed once, then deleted. The vault is transport, not a store.

**Receive**:
Resuming a **Handoff** (`/receive`). Scoped to context transfer *within* a task — a window reset, a worktree crossing — never cross-day continuity.
_Avoid_: "resume", "continue" — reserved session commands in Claude Code and pi.dev; a skill of either name is shadowed by the built-in.

**Placeholder body**:
An inbound ticket's queue form — Background, Problem statement and Triage notes. Written by **Triage** only where the body cannot already answer the first two; `/align` reads it as the ask, then replaces it with the spec.
_Avoid_: calling it a brief or a spec; it is the queue's shape.

**Surface**:
A concrete code location a piece of work claims to touch — a function, endpoint, resolver, type. Concrete enough to open in an editor. Branches (feature flags, env gates, A/B switches) that gate a surface are part of the surface, not separate from it.

**Target**:
Where a change will actually run: the exact artifact CI installs, the production data. A local copy of either is a **stand-in**, and a number measured on a stand-in doesn't hold for the target.
_Avoid_: live surface, prod (when CI is meant).

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

- The planning lane is `/align` → `/build` → `/shepherd`, with `/cut` between align and build when the work is a **Parent**, and `/spike`, `/research` and `/prototype` as align's routes for unknowns. A prose or settings ticket goes through `/build` without tdd. `/propose` is the branch that asks someone first. `/build`'s review is `/crucible`; `/review` and `/shepherd` invoke the same policy (ADR-0013).
- **Labels carry the state, the spec carries the plan.** `needs-alignment` means the spec, or a question in it, is still owed; `ready-to-cut` means a parent spec is agreed; `ready-to-build` means a child spec is agreed. `/align` and `/cut` set `ready-to-build`.
- Two lanes reach the takeable state: the **planning lane** (above) and the **inbound lane** (**triage** → placeholder, for work that arrived cold). One label set, two provenances; the inbound lane reaches no takeable state of its own — it queues into `needs-alignment`, and `/diagnose` leaves a ticket there too.
- **The running app is the proof.** Green alone isn't done: the **Verifier** proves each criterion on the running app, and crucible checks each criterion against the diff, walks the hunks, and mutates the changed lines only when a fix carries no test; unchecked Verify boxes keep the pull request a draft.
- **Children are vertical and cut ready to build.** `/cut` publishes each child with its acceptance criteria, seams and Verify steps, sized for one fresh build session; only a child with an open question goes back to `/align` first. A child is never a parent of another child.
- A greenfield frontend runs `design-system` twice around a `/prototype`: pass one writes the **DESIGN.md** knobs and tokens with **Motif**s empty, the prototype discovers the flavour on the first real screen, pass two distils the winner into motifs. Discovery is finished when a new screen can be built without stopping to ask.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.

## Flagged ambiguities

- **The contract pipeline** — the alignment body, **Pass**, **Verdict**, **Route** entries, **Slice comment**, **Destination**, **Readiness check** (`cut/READINESS.md`), **Scenario**, **Axis**, prose criteria with **witness**es, P0–P2 severities and the verified list → resolved: **removed** by ADR-0011. The oracle is now each acceptance criterion, tested in the build loop and proven on the running app (ADR-0013); a term from that list in a skill is drift to repoint.
- **Locked tests** — `/tester`, the validator, the lock check, stale locks, interface stubs approved in align, units, the Delegator, fresh builders per unit, behaviour lines, scratch tests, survivors, fix-round tables and rule questions → resolved: **removed** by ADR-0013. A term from that list in a skill is drift to repoint.
- **The ticketing lane shaped gauntlet-fitness** — ADR-0003, plus the **Edge**, **Gauntlet-fitness**, **Unfitness class**, **Grow-the-seam prep ticket**, **Ticket-lint** and **Stamper** terms → resolved: **removed**. `ticket-lint` no longer exists; ADR-0003 is superseded rather than deleted, and its premise is recorded there.
- **The agent-takeable label was guaranteed by construction** — ADR-0002, plus the *triage-free planning lane* → resolved: **reversed**. `/align` creates the ticket before it is buildable, so `needs-alignment` is a real intermediate state. See ADR-0005.
