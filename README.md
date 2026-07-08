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

- [challenge](engineering/challenge/SKILL.md) — Socratic coaching for architecture decisions and trade-offs before you commit to an approach
- [commit](engineering/commit/SKILL.md) — create a git commit with conventional commit message format
- [diagnose](engineering/diagnose/SKILL.md) — disciplined diagnosis loop for hard bugs and performance regressions (reproduce → minimise → hypothesise → instrument → fix → regression-test)
- [grilling](engineering/grilling/SKILL.md) — reusable interview loop (model-invoked): the relentless-questioning core shared by `grill-me` and `grill-with-docs`
- [grill-with-docs](engineering/grill-with-docs/SKILL.md) — stress-test a plan against the project's domain model, glossary, and ADRs; updates docs inline (and captures the session into the Obsidian Library if present)
- [handoff](engineering/handoff/SKILL.md) — compact the conversation into a handoff doc for a fresh session to pick up (written into the Obsidian vault's `Handoffs/` when present, else a tmp file)
- [improve-codebase-architecture](engineering/improve-codebase-architecture/SKILL.md) — find deepening opportunities informed by CONTEXT.md and ADRs
- [pickup](engineering/pickup/SKILL.md) — verification pass for a `ready-for-human` ticket; verify the agent brief against current code, then route to `/tdd`, `/diagnose`, or a targeted re-grill
- [pr](engineering/pr/SKILL.md) — create a GitHub pull request with a structured summary
- [receive](engineering/receive/SKILL.md) — resume an agent handoff from `Handoffs/`, then archive it (the session analogue of `pickup`)
- [review](engineering/review/SKILL.md) — review code in Hassan's voice: self-review the current branch in the terminal, or check a named PR out locally and post inline comments after confirmation
- [tdd](engineering/tdd/SKILL.md) — test-driven development with red-green-refactor loop
- [to-issues](engineering/to-issues/SKILL.md) — break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices
- [to-prd](engineering/to-prd/SKILL.md) — turn the current conversation into a PRD and publish it to the project issue tracker
- [to-proposal](engineering/to-proposal/SKILL.md) — turn a grilling into an argued proposal for a decision-maker and publish it to Notion (the proposal sibling of `to-prd`)
- [triage](engineering/triage/SKILL.md) — triage issues through a state machine driven by triage roles

## `productivity/` — meta-skills for working with me and Claude

- [grill-me](productivity/grill-me/SKILL.md) — interview me relentlessly about a plan until each branch of the decision tree resolves
- [write-a-skill](productivity/write-a-skill/SKILL.md) — create new agent skills with proper structure and progressive disclosure

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

# My day-to-day

The ones I reach for most:

- `grill-me` / `grill-with-docs` before any non-trivial change
- `tdd` to drive the implementation loop
- `diagnose` for anything broken
- `grill-with-docs` to shape fresh work, then route at close to the right output — `to-prd` → `to-issues` (a build, on GitHub), `to-proposal` (an argued recommendation, on Notion), or straight to `to-issues` for small work
- `triage` for inbound work (bugs from users, drafts from collaborators, stale tickets)
- `review` for reviewing my own branch, or other github PRs
- `commit` and `pr` to ship
- `morning-brief` → `log` (filled through the day by the workflow skills above) → `eod-summary` as the daily spine
