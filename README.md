# All of my mad agentic skills

[![skills.sh](https://skills.sh/b/canhassancode/skills)](https://skills.sh/canhassancode/skills)

> **Trying to build things can be hard, and I honestly think AI has made this harder as an Engineer, not easier.**

Before we'd go through the full SDLC cycle, requirements gathering, planning, designs, implementation, QA blah blah. But with AI you can write a prompt, set your claude code to bypass permissions, grab a cuppa, then realise "woah its done everything!"... the issue is what its actually built might look and feel like the real deal, but as it scales, as it hits real world scenarios, it rarely holds up. So here are a list of skills with huge inspiration from the incredible [Matt Pocock](https://github.com/mattpocock), with some of my personal favourite engineering authors, Robert C. Martin, Martin Fowler, Eric Evans, and more. Time to figure out how to remain an engineer in the world of AI.

# Setup

1. Run the skills.sh installer:

```
npx skills@latest add canhassancode/skills
```

2. Select the skills you want.
3. Donezo. Enjoy!
4. If you ever need to update the skills, run:

```
npx skills@latest update
```

# What's in the box

Skills are organised into folders by category. Each folder maps to a section below.

## `engineering/` — the core SDLC loop

- [align](engineering/align/SKILL.md) — plan a change before it's built: tier it by size and uncertainty, send unknowns to spike, research or prototype, red-team any boundary it touches in a fresh context, grill it in rounds, asking what someone will see with no recommendation attached, then write the parent or child spec once from the conversation into the ticket body on one yes; a big or foggy ask runs across sessions on a Resume line
- [bootstrap](engineering/bootstrap/SKILL.md) — one-time per-repo setup for both lanes: the triage-graph `tracker:` preference and the planning lane's `docs/agents/*.md` config (GitHub/Linear/GitLab/local)
- [build](engineering/build/SKILL.md) — build one ready-to-build ticket in one session and one writer: find what already exists, build test-first at the spec's seams, prove each criterion on the running app through a fresh verifier, self-review against the coding rules, run `crucible` at most twice and hand back a pull request — or stop when a criterion can't hold as written; companion [EXAMPLES.md](engineering/build/EXAMPLES.md)
- [codebase-design](engineering/codebase-design/SKILL.md) — deep-module design vocabulary, principles, and testability guidance (model-invocable; referenced by `tdd` and `improve-codebase-architecture`)
- [commit](engineering/commit/SKILL.md) — create a git commit with conventional commit message format
- [crucible](engineering/crucible/SKILL.md) — review a diff: each acceptance criterion against the spec, a correctness walk with probes of any boundary it touches, `CLAUDE.md` rules, the consumers of what changed and the claims against the diff, then mutation on the changed lines only when a fix carries no test; never edits the caller's tree or posts; companion [BASELINES.md](engineering/crucible/BASELINES.md)
- [cut](engineering/cut/SKILL.md) — publish a parent spec's children as `ready-to-build` sub-issues, each a tracer-bullet vertical slice with its acceptance criteria, seams, Verify steps and blocking edges, sized for one fresh build session; `needs-alignment` only for a child with an open question
- [design-system](engineering/design-system/SKILL.md) — interview a repo's brand knobs into a `DESIGN.md` and a token layer, then amend it as motifs are earned from prototypes; the invariant lives in [SYSTEM.md](engineering/design-system/SYSTEM.md), the flavour in the repo
- [diagnose](engineering/diagnose/SKILL.md) — disciplined diagnosis loop for hard bugs and performance regressions (reproduce → minimise → hypothesise → instrument → fix → regression-test)
- [domain-modeling](engineering/domain-modeling/SKILL.md) — build and maintain a project's domain model (model-invocable: challenge terms, sharpen language, stress-test with scenarios, prefer the user's own words, write each CONTEXT.md term as it settles and offer an ADR only when it earns one)
- [grilling](engineering/grilling/SKILL.md) — reusable interview loop (model-invoked): the relentless-questioning core behind `grill-me`: the whole frontier asked in rounds, every answer challenged against the evidence
- [handoff](engineering/handoff/SKILL.md) — compact the conversation into a handoff doc for a fresh session to pick up (written into the Obsidian vault's `Handoffs/` when present, else a tmp file)
- [improve-codebase-architecture](engineering/improve-codebase-architecture/SKILL.md) — find deepening opportunities informed by CONTEXT.md and ADRs
- [pr](engineering/pr/SKILL.md) — create a GitHub pull request with a structured summary
- [propose](engineering/propose/SKILL.md) — turn an aligned spec into an argued proposal for a decision-maker and publish it to the tracker, leaving the ticket at `awaiting-decision` until the answer goes back to `align`
- [prototype](engineering/prototype/SKILL.md) — build a throwaway prototype to answer a design question (logic or UI branch); model-invoked so `align`'s prototype route can reach it
- [receive](engineering/receive/SKILL.md) — resume an agent handoff from `Handoffs/`, then delete it
- [research](engineering/research/SKILL.md) — spin up a background agent to investigate a question against primary sources and write cited findings to a markdown file
- [retro](engineering/retro/SKILL.md) — read a ticket's pipeline transcripts, measure where time and turns went, check earlier retro changes against their signals, and apply skill changes that replace as much as they add
- [review](engineering/review/SKILL.md) — review a named GitHub PR in Hassan's voice: check the branch out locally, run `crucible` for the analysis, post inline comments after confirmation. With no argument it no longer self-reviews — that is `crucible` against a fixed point
- [shepherd](engineering/shepherd/SKILL.md) — take one open pull request through the review bot's rounds until every thread is settled, whatever the score: triage each thread, fix inside the spec test-first through `crucible`, reply with evidence, and ask before colleague review; started in a fresh session on the pull request `build` hands back, or on any other
- [spike](engineering/spike/SKILL.md) — answer one question about how something behaves by running the smallest throwaway code, inside a 15-minute timebox, reading production only through a read-only route and writing only with sandbox credentials, and return the answer with its command and output
- [tdd](engineering/tdd/SKILL.md) — test-driven development with red-green-refactor loop
- [triage](engineering/triage/SKILL.md) — queue work that arrived cold: classify it, name its route, write the placeholder body; `/triage sweep` groups a whole backlog into duplicates and families; turning it into a spec is `/align`'s

## `productivity/` — meta-skills for working with me and Claude

- [grill-me](productivity/grill-me/SKILL.md) — interview me relentlessly about a plan until each branch of the decision tree resolves
- [writing-great-skills](productivity/writing-great-skills/SKILL.md) — vocabulary and principles for predictable skills; companion [GLOSSARY.md](productivity/writing-great-skills/GLOSSARY.md)

## `personal/` — the Obsidian second brain

An Obsidian vault in two halves: **Library** for the world (external sources, agent-written) and **Profile/Personal** for Hassan (hand-edited). See the vault's own `CONTEXT.md`/`CONVENTIONS.md` for the model.

- [ask](personal/ask/SKILL.md) — answer a question from the brain, routed by query shape: grep for a named fact, index-first for a conceptual one
- [file](personal/file/SKILL.md) — file a personal document or self-fact into a domain folder or `Profile/`: OCR on intake, matter-as-unit with linked raws, supersede-don't-append fact hygiene; also drains the top item from `Inbox/`
- [ingest](personal/ingest/SKILL.md) — process an article, video, or book chapter into the Library wiki; also drains the top item from `Inbox/`
- [observe](personal/observe/SKILL.md) — append one timestamped observation to `Profile/observations.md`; called by nothing, drained by `drain`
- [drain](personal/drain/SKILL.md) — drain the observations file one item at a time, each into a change made in the same sitting

## `in-progress/` — works in progress, not yet released

- [system-map](in-progress/system-map/SKILL.md) — build a layered map of how a flow or domain concept spans multiple repos (UI → API → service → data)

## `deprecated/` — kept for reference, no longer recommended

- [validate](deprecated/validate/SKILL.md) — superseded by per-repo validation hooks
- [obsidian-vault](deprecated/obsidian-vault/SKILL.md) — superseded by the second-brain skills above (`ask`/`ingest`)
- [write-a-skill](deprecated/write-a-skill/SKILL.md) — superseded by [writing-great-skills](productivity/writing-great-skills/SKILL.md)
- [to-prd](deprecated/to-prd/SKILL.md) — superseded by the planning lane, [align](engineering/align/SKILL.md) → [cut](engineering/cut/SKILL.md); "spec" is the honest superset of PRD
- [to-issues](deprecated/to-issues/SKILL.md) — superseded by [cut](engineering/cut/SKILL.md); tracker-neutral "ticket", with blocking edges
- [setup-tracker](deprecated/setup-tracker/SKILL.md) — superseded by [bootstrap](engineering/bootstrap/SKILL.md); configures both lanes, not just the tracker preference
- [challenge](deprecated/challenge/SKILL.md) — superseded by [grill-me](productivity/grill-me/SKILL.md); the same Socratic pass, with a decision tree that has to resolve
- [pickup](deprecated/pickup/SKILL.md) — superseded by [build](engineering/build/SKILL.md), which takes a ticket reference and absorbs the stale-brief risk pickup existed to catch
- [inbox](deprecated/inbox/SKILL.md) — superseded by [ingest](personal/ingest/SKILL.md), which drains `Inbox/` as part of its own flow
- [morning-brief](deprecated/morning-brief/SKILL.md) — retired, not replaced; the daily Operating Loop and its `Journal/` are gone
- [eod-summary](deprecated/eod-summary/SKILL.md) — retired, not replaced; same reason as `morning-brief`
- [lint](deprecated/lint/SKILL.md) — retired, not replaced; the vault's surviving files are hand-written and don't generate hygiene debt
- [implement](deprecated/implement/SKILL.md) — superseded by [build](engineering/build/SKILL.md), which proves each criterion on the running app and puts the diff through `crucible` instead of resting on one session's judgement
- [code-review](deprecated/code-review/SKILL.md) — superseded by [crucible](engineering/crucible/SKILL.md), which carries its Standards, Structure and Design axes as baselines and is invoked by `build` and `review`
- [wayfinder](deprecated/wayfinder/SKILL.md) — superseded by [align](engineering/align/SKILL.md): the pass's Unresolved list is the map, and each entry's Route is the ticket type
- [tester](deprecated/tester/SKILL.md) — superseded by [build](engineering/build/SKILL.md) and [tdd](engineering/tdd/SKILL.md): tests are written test-first in the build loop, not locked ahead of it (ADR-0013)

# My day-to-day

The ones I reach for most:

- `align` before any non-trivial change
- **Planned work:** `align` — tier, red team, grill, spec → `build` → `shepherd`. Bigger than a session: `align` a parent spec → `cut` its children → `build` each in turn. An unknown goes to `spike`, `research` or `prototype` and lands in the spec's Decisions; a yes owed outside the room goes through `propose` and back to `align`.
- **New frontend repo:** `bootstrap` → `design-system` (knobs, tokens, empty motifs) → `prototype` the first screen → `design-system` again to distil the motifs → then the planned-work lane as normal.
- **Inbound work (triage lane):** `triage` for bugs from users, drafts from collaborators, stale tickets → `diagnose` for a confined bug, `align` for the rest → `build`.
- `diagnose` for anything broken; `crucible` for my own branch, `review` for posting on someone else's PR
