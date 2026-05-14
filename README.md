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
- [grill-with-docs](engineering/grill-with-docs/SKILL.md) — stress-test a plan against the project's domain model, glossary, and ADRs; updates docs inline
- [improve-codebase-architecture](engineering/improve-codebase-architecture/SKILL.md) — find deepening opportunities informed by CONTEXT.md and ADRs
- [pr](engineering/pr/SKILL.md) — create a GitHub pull request with a structured summary
- [tdd](engineering/tdd/SKILL.md) — test-driven development with red-green-refactor loop
- [to-issues](engineering/to-issues/SKILL.md) — break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices
- [to-prd](engineering/to-prd/SKILL.md) — turn the current conversation into a PRD and publish it to the project issue tracker
- [triage](engineering/triage/SKILL.md) — triage issues through a state machine driven by triage roles

## `productivity/` — meta-skills for working with me and Claude

- [grill-me](productivity/grill-me/SKILL.md) — interview me relentlessly about a plan until each branch of the decision tree resolves
- [write-a-skill](productivity/write-a-skill/SKILL.md) — create new agent skills with proper structure and progressive disclosure

## `personal/` — personal workflows

- [obsidian-vault](personal/obsidian-vault/SKILL.md) — search, create, and manage notes in the Obsidian vault with wikilinks and index notes

## `in-progress/` — works in progress, not yet released

- [system-map](in-progress/system-map/SKILL.md) — build a layered map of how a flow or domain concept spans multiple repos (UI → API → service → data)

## `deprecated/` — kept for reference, no longer recommended

- [validate](deprecated/validate/SKILL.md) — superseded by per-repo validation hooks

# My day-to-day

The ones I reach for most:

- `grill-me` / `grill-with-docs` before any non-trivial change
- `tdd` to drive the implementation loop
- `diagnose` for anything broken
- `to-prd` → `to-issues` → `triage` for shaping work
- `commit` and `pr` to ship
