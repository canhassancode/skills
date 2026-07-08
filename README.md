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

- [bootstrap](engineering/bootstrap/SKILL.md) — one-time per-repo setup for both lanes: the triage-graph `tracker:` preference and the planning lane's `docs/agents/*.md` config (GitHub/Linear/GitLab/local)
- [challenge](engineering/challenge/SKILL.md) — Socratic coaching for architecture decisions and trade-offs before you commit to an approach
- [code-review](engineering/code-review/SKILL.md) — two-axis review of a diff (Standards, with a Fowler smell baseline ‖ Spec) in parallel sub-agents; called by `implement`, runs alongside `review`
- [codebase-design](engineering/codebase-design/SKILL.md) — deep-module design vocabulary, principles, and testability guidance (model-invocable; referenced by `tdd` and `improve-codebase-architecture`)
- [commit](engineering/commit/SKILL.md) — create a git commit with conventional commit message format
- [diagnose](engineering/diagnose/SKILL.md) — disciplined diagnosis loop for hard bugs and performance regressions (reproduce → minimise → hypothesise → instrument → fix → regression-test)
- [domain-modeling](engineering/domain-modeling/SKILL.md) — build and maintain a project's domain model (model-invocable: challenge terms, sharpen language, stress-test with scenarios, update CONTEXT.md inline, offer ADRs)
- [grilling](engineering/grilling/SKILL.md) — reusable interview loop (model-invoked): the relentless-questioning core shared by `grill-me` and `grill-with-docs`
- [grill-with-docs](engineering/grill-with-docs/SKILL.md) — stress-test a plan against the project's domain model, glossary, and ADRs; updates docs inline (and captures the session into the Obsidian Library if present)
- [handoff](engineering/handoff/SKILL.md) — compact the conversation into a handoff doc for a fresh session to pick up (written into the Obsidian vault's `Handoffs/` when present, else a tmp file)
- [implement](engineering/implement/SKILL.md) — implement a spec or set of tickets: TDD at pre-agreed seams, regular typecheck, then `code-review` before committing
- [improve-codebase-architecture](engineering/improve-codebase-architecture/SKILL.md) — find deepening opportunities informed by CONTEXT.md and ADRs
- [pickup](engineering/pickup/SKILL.md) — verification pass for a `ready-for-human` ticket; verify the agent brief against current code, then route to `/tdd`, `/diagnose`, or a targeted re-grill
- [pr](engineering/pr/SKILL.md) — create a GitHub pull request with a structured summary
- [prototype](engineering/prototype/SKILL.md) — build a throwaway prototype to answer a design question (logic or UI branch); model-invoked so `wayfinder` can reach it
- [receive](engineering/receive/SKILL.md) — resume an agent handoff from `Handoffs/`, then archive it (the session analogue of `pickup`)
- [research](engineering/research/SKILL.md) — spin up a background agent to investigate a question against primary sources and write cited findings to a markdown file
- [review](engineering/review/SKILL.md) — review code in Hassan's voice: self-review the current branch in the terminal, or check a named PR out locally and post inline comments after confirmation
- [tdd](engineering/tdd/SKILL.md) — test-driven development with red-green-refactor loop
- [to-proposal](engineering/to-proposal/SKILL.md) — turn a grilling into an argued proposal for a decision-maker and publish it to Notion (the proposal sibling of `to-spec`)
- [to-spec](engineering/to-spec/SKILL.md) — synthesise the current conversation into a spec and publish it to the tracker as `ready-for-agent` (no triage); the planning lane's entry point
- [to-tickets](engineering/to-tickets/SKILL.md) — break a spec into tracer-bullet tickets with blocking edges, as native tracker links or a local `tickets.md`
- [triage](engineering/triage/SKILL.md) — triage inbound issues through a state machine driven by triage roles
- [wayfinder](engineering/wayfinder/SKILL.md) — chart an oversized, foggy plan as a map of investigation tickets (research/prototype/grilling/task) on the tracker, resolved one session at a time

## `productivity/` — meta-skills for working with me and Claude

- [grill-me](productivity/grill-me/SKILL.md) — interview me relentlessly about a plan until each branch of the decision tree resolves
- [writing-great-skills](productivity/writing-great-skills/SKILL.md) — vocabulary and principles for predictable skills; companion [GLOSSARY.md](productivity/writing-great-skills/GLOSSARY.md)

## `personal/` — the Obsidian second brain

An AI-operated Obsidian vault: a write-heavy **Operating Loop** (daily continuity) and a read-heavy **Library/Profile** wiki. See the vault's own `CONTEXT.md`/`CONVENTIONS.md` for the model.

- [morning-brief](personal/morning-brief/SKILL.md) — compile the day's cross-domain index (carried items, open issues, Inbox, open handoffs, Profile focus); self-heals an unclosed prior day
- [log](personal/log/SKILL.md) — append a timestamped entry to today's daily log (the living record between brief and summary); the spine the workflow skills write to on close
- [eod-summary](personal/eod-summary/SKILL.md) — consolidate the day's log: reconcile each Work Item's disposition (done / signed-off / carried) against what the log records, so unfinished work rolls forward with its reason
- [inbox](personal/inbox/SKILL.md) — triage raw captures into a Domain, the Library, a Work Item, or the bin
- [ingest](personal/ingest/SKILL.md) — process a source (or a grilling session) into the Library wiki
- [ask](personal/ask/SKILL.md) — answer a question from the brain, index-first (Library for the world, Profile for Hassan)
- [lint](personal/lint/SKILL.md) — sweep the vault for conformance to `CONVENTIONS.md` (Class A leaks, frontmatter, naming, archive markers, index reconcile)

## `in-progress/` — works in progress, not yet released

- [system-map](in-progress/system-map/SKILL.md) — build a layered map of how a flow or domain concept spans multiple repos (UI → API → service → data)

## `deprecated/` — kept for reference, no longer recommended

- [validate](deprecated/validate/SKILL.md) — superseded by per-repo validation hooks
- [obsidian-vault](deprecated/obsidian-vault/SKILL.md) — superseded by the second-brain skills above (`ask`/`ingest`/`inbox` + the Operating Loop)
- [write-a-skill](deprecated/write-a-skill/SKILL.md) — superseded by [writing-great-skills](productivity/writing-great-skills/SKILL.md)
- [to-prd](deprecated/to-prd/SKILL.md) — superseded by [to-spec](engineering/to-spec/SKILL.md); "spec" is the honest superset of PRD
- [to-issues](deprecated/to-issues/SKILL.md) — superseded by [to-tickets](engineering/to-tickets/SKILL.md); tracker-neutral "ticket", with blocking edges
- [setup-tracker](deprecated/setup-tracker/SKILL.md) — superseded by [bootstrap](engineering/bootstrap/SKILL.md); configures both lanes, not just the tracker preference

# My day-to-day

The ones I reach for most:

- `grill-me` / `grill-with-docs` before any non-trivial change
- **Planned work (triage-free lane):** `grill-with-docs` — or `wayfinder` when it's too big for one session — to shape it → `to-spec` → `to-tickets` → `implement` each ticket → `code-review` → `commit`/`pr`. A grill that turns out to be an argued recommendation rather than a build routes to `to-proposal` (Notion) instead.
- **Inbound work (triage lane):** `triage` for bugs from users, drafts from collaborators, stale tickets → `pickup` a `ready-for-human` ticket → `tdd` / `diagnose`.
- `diagnose` for anything broken; `review` for reviewing my own branch or other GitHub PRs
- `morning-brief` → `log` (filled through the day by the workflow skills above) → `eod-summary` as the daily spine
