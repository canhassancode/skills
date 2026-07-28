---
created: 2026-06-14
sources: grill-with-docs session (2026-06-14), no raw
---

# OpenAI Tiered TDD Translation — Work Employment Sessions

A `grill`-sourced design session translating the DeepSeek-specific pi subagent
workflow from [Pi Subagent Workflow Design](./pi-subagent-workflow-design.md) into an OpenAI-model
equivalent for work Employment sessions, with profile-aware configuration
so the same harness works across personal (DeepSeek) and work (OpenAI) without
manual toggling.

## Model mapping

Researched June 2026: OpenAI's current lineup is gpt-5.5 (flagship, $5/$30),
gpt-5.4 ($2.50/$15), gpt-5.4-mini ($0.75/$4.50). DeepSeek V4-Pro is competitive
with GPT-5.4 on coding (leads LiveCodeBench 93.5, trails Terminal-Bench 67.9 vs
75.1). GPT-5.5 is a step above both but the cost premium isn't justified for a
coding harness given a finite credit budget.

| Role | Model | Reasoning effort | Rationale |
|---|---|---|---|
| **Parent orchestrator** | gpt-5.4 | high | Adversarial reasoning. GPT-5.4 leads on agentic benchmarks over V4-Pro |
| **Scout** (code trace) | gpt-5.4-mini | high | Mechanical grep/read — reasoning barely matters |
| **Ask** (vault sweep) | gpt-5.4-mini | high | Index-first retrieval, mechanical |
| **Researcher** (external docs) | gpt-5.4 | high | Synthesis benefits from stronger reasoning |
| **Reviewer** | gpt-5.4 | high | Diff inspection, structural critique |
| **Test writer** | gpt-5.4-mini | high | Mechanical — writes assertions from spec |
| **Implementer** (default) | gpt-5.4-mini | high | Escalate to gpt-5.4-high for multi-file invariants |
| **Refactorer** | gpt-5.4 | high | Structural reasoning rewards deeper thinking |

**Cost context:** gpt-5.4-mini output at $4.50/M is 16× V4-Flash ($0.28/M).
gpt-5.4 at $15/M is 4.3× V4-Pro ($3.48/M). Mini preferred for all mechanical
roles; gpt-5.4 reserved for reasoning.

## Configuration design

### Problem

The dotfiles repo (`pi/`) is symlinked to `~/.pi/agent/` on both machines, but
the personal machine only has `$DEEPSEEK_API_KEY` and the work machine only has
`$OPENAI_API_KEY`. A single shared `settings.json` can't encode both providers.

### Solution

`settings.json` is the **only** machine-specific file. Everything else stays
symlinked and shared.

- **Personal machine:** `~/.pi/agent/settings.json` → symlinked to
  `dotfiles/pi/.pi/agent/settings.json` (DeepSeek defaults)
- **Work machine:** `~/.pi/agent/settings.json` → local copy of
  `dotfiles/pi/.pi/agent/settings.openai.json` (OpenAI mapping)
- Agent files, AGENTS.md, CONTEXT.md, extensions — all symlinked, portable

### Mechanism

Agent files carry `model:` in frontmatter as DeepSeek defaults. `agentOverrides`
in settings.json take precedence. The OpenAI settings override every TDD agent's
model to the OpenAI equivalent.

```
Agent file:        model: deepseek-v4-flash
Settings override: model: gpt-5.4-mini    ← wins
```

The override was verified: `agentOverrides.model` patches on top of the agent
definition and takes precedence over frontmatter `model:`.

### Settings files

`settings.json` (DeepSeek — personal):
- `defaultProvider: "deepseek"`, `defaultModel: "deepseek-v4-pro"`, `defaultThinkingLevel: "xhigh"`
- Context subagents: V4-Pro at high thinking; TDD agents: V4-Flash/V4-Pro

`settings.openai.json` (OpenAI — Employment):
- `defaultProvider: "openai"`, `defaultModel: "gpt-5.4"`, `defaultThinkingLevel: "high"`
- Scout/ask: gpt-5.4-mini; researcher/reviewer/refactorer: gpt-5.4; TDD writers: gpt-5.4-mini

## What stays the same

The structural design ports cleanly regardless of model:
- 3-agent TDD loop with context isolation (test-writer → implementer → refactorer)
- Planning fan-out pattern (scout + ask + researcher parallel async)
- Per-slice commits
- HITL checkpoints at RED gate
- Inside-out slice ordering (domain → domain-service → application → infrastructure)

## Open

- No GPT-5.5 vs V4-Pro head-to-head benchmarks exist yet (V4 shipped before GPT-5.5)
- gpt-5.4-mini reasoning_effort support at `high` level needs empirical validation
  on the researcher role — if quality drops, escalate researcher to gpt-5.4
- Cost guardrails deferred to OpenAI account-level budget caps (no pi-level warning
  extension needed for now)

## Related

[Pi Subagent Workflow Design](./pi-subagent-workflow-design.md) · pi.dev
