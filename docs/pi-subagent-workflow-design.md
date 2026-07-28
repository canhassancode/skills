---
created: 2026-06-14
sources: grill-with-docs session (2026-06-14), no raw
---

# Pi Subagent Workflow Design — Tiered Models · TDD Loop · Planning Fan-out

A `grill`-sourced design session that resolved the deferred subagent context-sweep
from the 2026-06-10 daily-workflow redesign grill (retired) and extended it into a full pi subagent workflow:
planning fan-out → HITL grilling → pickup → TDD implementation loop.

## Key decisions

### 1. Tiered thinking model

| Role | Model | Thinking |
|---|---|---|
| Parent orchestrator | deepseek-v4-pro | xhigh |
| Context subagents (scout, ask, researcher) | deepseek-v4-pro | high |
| TDD test-writer | deepseek-v4-flash | high |
| TDD implementer | deepseek-v4-flash (default) / v4-pro (complex) | high |
| TDD refactorer | deepseek-v4-pro | high |
| Reviewer | deepseek-v4-pro | high |

The parent at xhigh is the single adversarial reasoner. All subagents run high —
mechanical retrieval and implementation don't need adversarial depth. V4-Flash is
~20× cheaper than V4-Pro at output ($0.28/M vs $3.48/M) and sufficient for
test generation and straightforward implementation (5/5 on code-implement benchmarks).

### 2. Planning fan-out (resolves the deferred Daily Workflow Redesign item)

Three parallel async subagents before HITL grilling:
- **scout**: code trace (follow every request path, enumerate branches), consumer hunt
  (grep reads of every changed contract), feature-flag sweep — the three code-facing
  passes from grill-with-docs's four-pass discipline, one agent, one filesystem
- **ask**: vault sweep — query the Library for prior grillings, ingested articles,
  Profile focus bearing on the topic
- **researcher**: external docs, ecosystem behaviour, recent changes, primary sources

Parent reads CONTEXT.md/ADRs directly while subagents run. Execute inline, not via
saved chain (HITL is inherently interactive).

### 3. TDD implementation loop — context-isolated 3-agent pattern

Converged from multiple independent implementations (alexop.dev, glebis/claude-skills,
greyhaven-ai, elasticLove1). The architectural invariant: each phase runs in a fresh
context that sees only what it needs, preventing the LLM from "cheating" by leaking
implementation intent into test design.

| Agent | Sees | Must not see |
|---|---|---|
| Test Writer (RED) | Slice spec, API signatures, framework conventions | Implementation code |
| Implementer (GREEN) | Failing test + error output only | The spec |
| Refactorer (REFACTOR) | All code + green tests | The spec |

Flow: pickup verifies brief → decompose into vertical slices → per slice:
RED (test writer, V4-Flash) → GREEN (implementer, V4-Flash) → REFACTOR
(refactorer, V4-Pro) → parent invokes `/commit`. One commit per slice.

Vertical slice ordering: domain → domain-service → application → infrastructure
(inside-out — builds real objects before tests that use them).

### 4. V4-Flash economics

At phase-routed usage (Pro for reasoning/refactoring, Flash for test-writing and
routine implementation), a typical coding day lands at ~$0.80 vs $2.26 for 100% Pro.
Flash costs $0.14/M input, $0.28/M output; Pro costs $1.74/M input, $3.48/M output
(list pricing). Cache hits on both models are aggressive (80-92% off input).

### 5. Configuration surface

Stored in dotfiles (`pi/` package):
- `pi/.pi/agent/settings.json` — `defaultThinkingLevel: xhigh` +
  `subagents.agentOverrides` (scout, ask, researcher, reviewer, worker → high)
- `pi/.pi/agent/AGENTS.md` — new `## Subagents` section + pointer to `pi/CONTEXT.md`
- `pi/CONTEXT.md` — full conventions document (model tiering, fan-out pattern,
  TDD loop, context isolation, guardrails)

Custom TDD agents created and symlinked: `tdd-test-writer` (V4-Flash),
`tdd-implementer` (V4-Flash), `tdd-refactorer` (V4-Pro).

## Sharpest insights

- **Subagents don't inherit parent thinking level automatically** — tested during the
  session. Verdict: add explicit `agentOverrides` in settings.json rather than relying
  on inheritance. Cost is near-zero (one JSON block, already dotfiles-tracked).
- **The context-isolation argument is model-agnostic.** The 3-agent TDD pattern ports
  cleanly to OpenAI at work — same structure, different model mappings. A separate
  grill session for the OpenAI translation is recommended.
- **Skills auto-register as subagents in pi** — demonstrated with `ask`. Any
  standalone-retrieval skill works; interactive skills (grill, tdd, pickup) don't
  make sense as subagents.
- **Grill output stays a fan-out, not a pipeline** — this design routes to Library
  capture + config, not a PRD or issues. The close-routing menu from
  the 2026-06-10 daily-workflow redesign grill (retired) is reinforced: a grill is a thinking artifact, not
  automatically a build spec.

## Status

Implemented 2026-06-14. Configuration written to dotfiles (`pi/CONTEXT.md`,
`AGENTS.md` and `settings.json` updated, TDD agent files created and
symlinked). Deferred: OpenAI-tiered TDD translation for work Employment sessions.

## Related

the 2026-06-10 daily-workflow redesign grill (retired) · pi.dev · Agent Inner Loop · DeepSeek-V4
