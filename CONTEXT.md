# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Skills compose by **invocation** — one skill may invoke another via the Skill tool (e.g. `/build` invokes `/crucible`). **Inlining** (copy-pasting another skill's procedure into your own body) is forbidden. Invocation is a pointer; inlining is duplication that drifts.

**Operator**:
The human the lane serves: approves the spec, the interface and the locked tests, supplies what a run cannot reach, ticks the pull request's unchecked Verify boxes, merges, and retires skills. Not in a build's per-unit path — a fallback the run stops for, never a station it waits at.
_Avoid_: user, developer, owner.

**Align**:
The planning lane's entrance: tier the ask, red-team it, agree a **Spec**, and — for a **Child** — approve its interface and lock its tests, so the build has nothing left to decide. Every question follows `grilling`; facts come from subagents, never from the operator. One child per session; a build that stops on a locked test comes back here.
_Avoid_: grilling, interview, discovery, pass.

**Tier**:
Where an ask sits on two questions: does it fit one session, and does anyone know enough to spec it? Size decides **Parent** or **Child**; uncertainty decides whether to explore first. Above the grid, a one-sentence diff needs no plan. Home: `engineering/align/references/tiers.md`.
_Avoid_: complexity, t-shirt size.

**Spike**:
One question about how something behaves, answered by the smallest throwaway code that shows it inside a 15-minute timebox, with sandbox credentials only. Returns the answer and its evidence; the code is never kept. A fact written down somewhere is `/research`'s; a shape the operator must see is `/prototype`'s.
_Avoid_: probe, experiment, prototype.

**Red team**:
A fresh subagent briefed to argue against the ask before the spec is written, returning **go**, **shrink** or **no-go**. The operator decides; a no-go ends at `wontfix`.
_Avoid_: review, critique.

**Spec**:
The plan for one capability, held as its **Ticket**'s body and never carrying status. Two shapes: a **Parent** and a **Child**. Settled questions live in its Decisions as dated `Q → A` lines. Supersedes the old *PRD* and the alignment body.
_Avoid_: PRD, contract, requirements doc.

**Parent**:
A spec too big for one session: the Goal, Out of scope, the Shape every child builds into, the Rules every child follows, and the Children list. It carries no interface and no tests, has no branch, and its ticket wears `ready-to-cut` until `/cut` publishes the children.
_Avoid_: epic, container, project.

**Child**:
A spec that fits one session — one capability a user or caller could notice on its own, about six **Behaviour line**s, at most one public interface and one port. Carries Goal, Context, Interface, Behaviour, Out of scope, Done when, **Verify** and Decisions; its stubs and locked tests live on `feat/<capability>`. Vertical, never a layer.
_Avoid_: slice, story, task.

**Behaviour line**:
One sentence in a child's Behaviour section, saying what the capability does in a case that matters. Each becomes a **Locked test** titled with exactly that sentence.
_Avoid_: acceptance criterion, scenario, requirement.

**Locked test**:
A test `/tester` writes from the approved spec and interface before any implementation, proven red for the right reason, approved by the operator and committed as `test: lock <capability> tests`. The file suffix is the lock — `.acceptance.`, `.properties.`, `.contract.`, or an `e2e/` directory. Read-only to everyone after that commit: a hook blocks edits as they happen, and the lock check fails the branch if one changed. An implementer who thinks one is wrong stops and says so.
_Avoid_: witness, criterion, spec test.

**Scratch test**:
A test the implementer writes outside the locked files while building. Kept only if it kills a mutant the locked tests miss; otherwise it goes on **crucible**'s **Prune list**.
_Avoid_: unit test — the layer is named by who owns it, not by its scope.

**Verify**:
A child spec's section agreeing, at `/align`, how to see the change working on the running app — the start command, the endpoint, the page. `/build`'s **Verifier** runs it; a step it can't run becomes an unchecked box in the pull request for the operator. `none — <why>` is allowed.
_Avoid_: QA, manual test, acceptance.

**Cut**:
`/cut` publishes a parent's Children list as sub-issues at `needs-alignment`, each with a goal line and draft behaviour lines drawn only from the parent, blocking edges set in build order. It decides nothing: a child the parent doesn't cover is a question, and each child is aligned just before it is built.
_Avoid_: breakdown, split, slicing.

**Build**:
The act that makes a child's locked tests green: one branch, a sequential loop of **Unit**s, each in a fresh **Builder**, then **crucible** once over the branch, the **Verifier** on the running app, one fix round, and the pull request. The parent session — the **Delegator** — holds the spec, the unit list and the results, never a diff. One writer per checkout. Stops instead of working around a wrong locked test, an interface gap, missing access or a spec change. Succeeds `/implement`, now deprecated.
_Avoid_: implement, execute, run.

**Fit**:
`/build`'s second step: typecheck, lint, the locked command, the full suite and the Verify start command, each run once at the base. A command the repo lacks is recorded as absent; a missing service or credential stops the run before it writes.
_Avoid_: setup, onboarding, environment.

**Unit**:
A group of locked tests one fresh **Builder** turns green, ordered so each starts from the last one's green tree, committed once on green. A child needing more than a few units goes back to `/cut`.
_Avoid_: layer, chunk, slice.

**Builder**:
One fresh subagent that builds one **Unit**, or one fix round — never a station that persists. It loops typecheck, lint, the locked tests and the full suite; follows `CLAUDE.md`; writes scratch tests where they help; never edits a locked file or shapes code to a test's inputs; and commits once, on green.
_Avoid_: agent, worker — those are the transport, not the role.

**Verifier**:
A fresh subagent that runs a child's **Verify** steps against the running app without ever reading the code or the tests, reporting each step passed, failed or not run.
_Avoid_: QA, tester.

**Review**:
The **policy** that vets a diff before it goes anywhere: a build's branch, a shepherd's fix, or a named pull request. Implemented by `/crucible`, which never edits the caller's tree and never posts; `/review` owns the voice and the posting, `/shepherd` the bot's rounds, and `/code-review` is deprecated into it.
_Avoid_: the review seam — *seam* keeps its codebase-design sense — and code review, linting.

**Finding**:
One question **Review** asks, carrying the evidence that raised it. Its class is **behaviour**, **claim**, **rule** (a broken `CLAUDE.md` rule) or **test**; its route is **fix**, **spec-change** (acting would change a behaviour line, so `/align`), **product-call** (the operator's, with a safe default) or **suppressed** (the spec or a settled thread already decided it). A baseline smell is a note, never a finding.
_Avoid_: comment, defect, issue, severity.

**Prune list**:
Crucible's list of this diff's scratch tests that kill no mutant the locked tests and the kept tests miss. `/build` deletes them in one `test: prune scratch tests` commit. Locked tests and tests older than the diff are never on it.
_Avoid_: dead tests, cleanup.

**Survivor**:
A mutant on a changed line that no test kills — returned as a question about behaviour the spec may not name, never as a test to write.
_Avoid_: gap, missing test.

**Ticket**:
A tracker node. Its body is the **Spec**, a parent's or a child's, written by `/align`. Its label is the work's state. The **frontier** is every ticket whose blockers are closed: the work takeable now.
_Avoid_: issue, story.

**Session comment**:
The one comment each `/align`, `/cut` or `/build` session posts on its ticket, carrying only what moved. A build's ends with a Resume line when its window filled.
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

- The planning lane is `/align` → `/tester` (inside align) → `/build` → `/shepherd`, with `/cut` between align and build when the work is a **Parent**, and `/spike`, `/research` and `/prototype` as align's routes for unknowns. `/propose` is the branch that asks someone first. `/build`'s engine is `/crucible`; `/review` and `/shepherd` invoke the same policy (ADR-0009, ADR-0011).
- **Labels carry the state, the spec carries the plan.** `needs-alignment` means the spec, interface or locked tests are still owed; `ready-to-cut` means a parent spec is agreed; `ready-to-build` means locked tests are committed. Only `/align` sets `ready-to-build`.
- Two lanes reach the takeable state: the **planning lane** (above) and the **inbound lane** (**triage** → placeholder, for work that arrived cold). One label set, two provenances; the inbound lane reaches no takeable state of its own — it queues into `needs-alignment`, and `/diagnose` leaves a ticket there too.
- **Locked tests are the contract.** Green alone isn't done: crucible checks the lock, mutates the diff, prunes scratch tests and walks the hunks; the **Verifier** checks the running app; unchecked Verify boxes go to the operator.
- **Children are vertical and planned just in time.** `/cut` publishes drafts; each child gets its interface and tests from its own `/align`, because a quarter of later slices in this library's trackers changed contract after a sibling merged. A child is never a parent of another child.
- A greenfield frontend runs `design-system` twice around a `/prototype`: pass one writes the **DESIGN.md** knobs and tokens with **Motif**s empty, the prototype discovers the flavour on the first real screen, pass two distils the winner into motifs. Discovery is finished when a new screen can be built without stopping to ask.
- A skill's relationship to **upstream** — **Synced**, **Adapted**, **Forked** — governs how it is edited. See `## Upstream` in `CLAUDE.md`.

## Flagged ambiguities

- **The contract pipeline** — the alignment body, **Pass**, **Verdict**, **Route** entries, **Slice comment**, **Destination**, **Readiness check** (`cut/READINESS.md`), **Scenario**, **Axis**, prose criteria with **witness**es, P0–P2 severities and the verified list → resolved: **removed** by ADR-0011. The oracle is now locked tests written from the spec before the code; a term from that list in a skill is drift to repoint.
- **The ticketing lane shaped gauntlet-fitness** — ADR-0003, plus the **Edge**, **Gauntlet-fitness**, **Unfitness class**, **Grow-the-seam prep ticket**, **Ticket-lint** and **Stamper** terms → resolved: **removed**. `ticket-lint` no longer exists; ADR-0003 is superseded rather than deleted, and its premise is recorded there.
- **The agent-takeable label was guaranteed by construction** — ADR-0002, plus the *triage-free planning lane* → resolved: **reversed**. `/align` creates the ticket before it is buildable, so `needs-alignment` is a real intermediate state. See ADR-0005.
