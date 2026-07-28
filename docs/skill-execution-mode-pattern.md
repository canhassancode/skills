---
created: 2026-06-14
updated: 2026-06-14
source: grill-with-docs (session)
---

# Skill Execution-Mode Pattern (grill)

Grilling session that designed how skills declare whether to use pi subagents or run linearly. Triggered when the planning fan-out (scout+ask+researcher) failed to fire in a real session — the model ignored both the execution-mode block and an explicit "use subagents" instruction from the user.

## Root cause (two failures)

1. **pi/CONTEXT.md was unreachable.** The AGENTS.md reference `pi/CONTEXT.md` resolved relative to the project root. In any repo that wasn't the dotfiles repo, the file didn't exist — pi had no way to learn what scout/ask/researcher were or the fan-out pattern. Fixed by moving `CONTEXT.md` into `~/.pi/agent/` (global pi directory, managed via stow) and updating all AGENTS.md references.

2. **The execution-mode block was passive, not imperative.** The original block said "Offer the user a choice… Default to linear." This is a suggestion the model silently ignores — the skill's concrete procedure ("explore the codebase") wins via recency bias. Fixed by making it step 1 of the skill's own numbered procedure: "1. Before exploring, ask: 'Fan-out (scout + ask + researcher) or linear?'"

## Design

### Two-tier pattern

| Tier | Skills | Behaviour |
|------|--------|-----------|
| **HITL choice** | grill-with-docs, grill-me | Ask user: fan-out or linear? If no answer or subagents unavailable, go linear |
| **Subagent-default** | tdd | Context-isolated loop (test-writer → implementer → refactorer). Fall back linear only if unavailable |

Skills that don't need subagents (pickup, diagnose, improve-codebase-architecture, commit, log, etc.) have no execution-mode block.

### Where the directive lives

In the SKILL.md body, as step 1 of the procedure — not in frontmatter (stripped before model sees it), not in a separate section (model treats as passive metadata). Must be an imperative numbered step the procedure can't start without.

### The Claude Code blind spot

Claude Code never reads `pi/CONTEXT.md`. Skills must be self-contained — the execution-mode block degrades gracefully ("if subagents unavailable, proceed linearly") for when the skill runs under Claude Code.

## External evidence

Researcher subagent confirmed: no agent harness has solved the meta-instruction vs. concrete-procedure conflict. Claude Code issue #16506 documents the exact failure ("Subagents MUST be used at ALL times" ignored). The arxiv paper (2606.07808) decomposes instruction hierarchy failures into identification/resolution/realization — realization failures (model knows but still violates) dominate in safety conflicts. The U-shaped attention curve means critical rules must appear at both start and end of the prompt; the compliance ceiling (~80K tokens) means fewer rules outperform more.

## Key decisions

- Grilling fan-out is a **luxury, not a necessity** (~$0.15/session). TDD context isolation earns its keep (prevents LLM cheating — implementation intent leaking into test design).
- Skills propagate via `~/repos/skills/` → copy to `~/.agents/skills/` → both pi and Claude Code pick up (symlinks). Single source of truth.
- The stow conflict was resolved by moving 5 files into the dotfiles tree (TDD agents, mcp.json, settings.json, CONTEXT.md) — now every `~/.pi/agent/` file is stow-managed.

## Related
pi.dev · the 2026-06-10 daily-workflow redesign grill (retired) · [Pi Subagent Workflow Design](./pi-subagent-workflow-design.md)
